Attestor
=====

Validations and policies for immutable Ruby objects

[![Gem Version](https://img.shields.io/gem/v/attestor.svg?style=flat)][gem]
[![Build Status](https://img.shields.io/travis/nepalez/attestor/master.svg?style=flat)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/nepalez/attestor.svg?style=flat)][gemnasium]
[![Code Climate](https://img.shields.io/codeclimate/github/nepalez/attestor.svg?style=flat)][codeclimate]
[![Coverage](https://img.shields.io/coveralls/nepalez/attestor.svg?style=flat)][coveralls]
[![Inline docs](http://inch-ci.org/github/nepalez/attestor.svg)][inch]

[codeclimate]: https://codeclimate.com/github/nepalez/attestor
[coveralls]: https://coveralls.io/r/nepalez/attestor
[gem]: https://rubygems.org/gems/attestor
[gemnasium]: https://gemnasium.com/nepalez/attestor
[travis]: https://travis-ci.org/nepalez/attestor
[inch]: https://inch-ci.org/github/nepalez/attestor

Motivation
----------

I like the [ActiveModel::Validations] more than any other part of the whole [Rails]. The more I like it the more painful the problem that **it mutates validated objects**.

Every time you run validations, the collection of object's `#errors` is cleared and populated with new messages. So you can't validate frozen (immutable) objects without magic tricks.

To solve the problem, the `attestor` gem:

* Provides a simplest API for validating immutable objects.
* Makes it possible to isolate validators (as [policy objects]) from their targets.
* Allows policy objects to be composed by logical operations to provide complex policies.

[ActiveModel::Validations]: http://apidock.com/rails/ActiveModel/Validations
[Rails]: http://rubyonrails.org/
[policy objects]: http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/

Approach
--------

Instead of collecting errors inside the object, the module defines two instance methods:

* `validate!` raises an exception (`Attestor::InvalidError`), that carries errors outside of the object.
* `validate` - the safe version of `validate!`. It rescues from the exception and returns a report object, that carries the exception as well as its error messages.

In both cases the inspected object stays untouched (and can be made immutable).

Installation
------------

Add this line to your application's Gemfile:

```ruby
# Gemfile
gem "attestor"
```

Then execute:

```
bundle
```

Or add it manually:

```
gem install attestor
```

Base Use
--------

Declare validation in the same way as ActiveModel's `.validate` method does:

```ruby
Transfer = Struct.new(:debet, :credit) do
  include Attestor::Validations

  validate :consistent

  private

  def consistent
    fraud = credit.sum - debet.sum
    invalid :inconsistent, fraud: fraud if fraud != 0
  end
end
```

Alternatively, you can describe validation in a block, executed in an instance's scope:

```ruby
class Transfer
  # ...
  validate { invalid :inconsistent if credit.sum != debet.sum }
end
```

The `#invalid` method translates its argument and raises an exception with the resulting message.

```yaml
# config/locales/en.yml
---
en:
  attestor:
    errors:
      transfer:
        inconsistent: "Credit differs from debet by %{fraud}"
```

To validate an object, use its `#validate!` method:

```ruby
debet  = OpenStruct.new(sum: 100)
credit = OpenStruct.new(sum: 90)
fraud_transfer = Transfer.new(debet, credit)

begin
  transfer.validate!       # with the bang
rescue Attestor::InvalidError => error
  error.object == transfer # => true
  error.messages           # => ["Credit differs from debet by 10"]
end
```

Alternatively use the safe version `#validate`.
It rescues from an exception and returns a corresponding report:

```ruby
report = transfer.validate  # without the bang

report.valid?               # => false
report.invalid?             # => true
report.object == transfer   # => true
report.messages             # => ["Credit differs from debet by 10"]
report.error                # => <Attestor::InvalidError ...>
```

Use of Contexts
---------------

Sometimes you need to validate the object agaist the subset of validations, not all of them.

To do this use `:except` and `:only` options of the `.validate` class method.

```ruby
class Transfer
  # ...
  validate :consistent, except: :steal_of_money
end
```

Then call a `#validate!`/`#validate` methods with that context:

```ruby
fraud_transfer.validate!                 # => InvalidError
fraud_transfer.validate! :steal_of_money # => PASSES!
```

You can use the same validator several times with different contexts. They will be used independently from each other.

```ruby
class Transfer
  # ...

  validate :consistent, only: :fair_trade, :consistent
  validate :consistent, only: :legal

end
```

You can group validations that uses shared context:

```ruby
class Transfer

  # This is the same as:
  #
  # validate :consistent, only: :fair_trade
  # validate :limited, only: :fair_trade
  validations only: :fair_trade do
    validate :consistent
    validate :limited
  end
end
```

Delegation
----------

Extract validator to an external object (policy), that responds to `validate!`.

```ruby
ConsistentTransfer = Struct.new(:debet, :credit) do
  include Attestor::Validations

  def validate!
    invalid :inconsistent unless debet.sum == credit.sum
  end
end
```

Then use `validates` helper (with an "s" at the end):

```ruby
class Transfer 
  # ...
  validates { ConsistentTransfer.new(:debet, :credit) }
end
```

or by method name:

```ruby
class Transfer
  # ...
  validates :consistent_transfer

  def consistent_transfer
    ConsistentTransfer.new(:debet, :credit)
  end
```

The difference between `.validate :something` and `.validates :something` methods is that:
* `.validate` expects `#something` to make checks and raise error by itself
* `.validates` expects `#something` to respond to `#validate!`

Policy Objects
--------------

Basically the policy includes `Attestor::Validations` with additional methods to allow logical compositions.

To create a policy as a `Struct` use the builder:

```ruby
ConsistencyPolicy = Attestor::Policy.new(:debet, :credit) do
  def validate!
    fraud = credit - debet
    invalid :inconsistent, fraud: fraud if fraud != 0
  end
end
```

If you doesn't need `Struct`, include `Attestor::Policy` to the class and initialize its arguments somehow else:

```ruby
class ConsistencyPolicy
  include Attestor::Policy
  # ...
end
```

Policy objects can be used by `validates` method like other objects that respond to `#validate!`:

```ruby
class Transfer
  # ...
  validates { ConsistencyPolicy.new(debet, credit) }
end
```

Complex Policies
----------------

Policies (assertions) can be combined by logical methods.

Suppose we have two policy objects:

```ruby
valid_policy.validate.valid?   # => true
invalid_policy.validate.valid? # => false
```

Use factory methods to provide compositions:

```ruby
complex_policy = valid_policy.not
complex_policy.validate! # => fails

complex_policy = valid_policy.and(valid_policy, invalid_policy)
complex_policy.validate! # => fails

complex_policy = invalid_policy.or(invalid_policy, valid_policy)
complex_policy.validate! # => passes

complex_policy = valid_policy.xor(valid_poicy, valid_policy)
complex_policy.validate! # => fails

complex_policy = valid_policy.xor(valid_poicy, invalid_policy)
complex_policy.validate! # => passes
```

The `or`, `and` and `xor` methods called without argument(s) don't provide a policy object. They return lazy composer, expecting `#not` method.

```ruby
complex_policy = valid_policy.and.not(invalid_policy, invalid_policy)
# this is the same as:
valid_policy.and(invalid_policy.not, invalid_policy.not)
```

If you prefer wrapping to chaining, use the `Policy` factory methods instead:

```ruby
Policy.and(valid_policy, invalid_policy)
# this is the same as: valid_policy.and(invalid_policy)

Policy.or(valid_policy, invalid_policy)
# this is the same as: valid_policy.or(invalid_policy)

Policy.xor(valid_policy, invalid_policy)
# this is the same as: valid_policy.xor(invalid_policy)

Policy.not(valid_policy)
# this is the same as: valid_policy.not
```

As before, you can use any number of policies (except for negation of a single policy) at any number of nesting.

RSpec helpers
-------------

In a RSpec tests you can use spies for valid and invalid objects:

* `valid_spy` is a spy that returns `nil` in response to `#validate!` and valid report in responce to `#validate`.
* `invalid_spy` raises on `#validate!` and returns invalid report in responce to `#validate` method call.

```ruby
require "attestor/rspec"

describe "something" do

  let(:valid_object)   { valid_spy   }
  let(:invalid_object) { invalid_spy }

  # ...
end
```

To check whether an arbitrary object is valid, simply use `#validate` method's result:

```ruby
expect(object.validate).to be_valid
expect(object.validate).to be_invalid
```

Compatibility
-------------

Tested under rubies compatible to rubies with API 1.9.3+:

* MRI 1.9.3+
* Rubinius-2 (modes 1.9+)
* JRuby 9.0.0.0.pre1+

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

[RSpec]: http://rspec.info
[hexx-suit]: https://github.com/nepalez/hexx-suit

Contributing
------------

* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE).
* Fork the project
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

Latest Changes
--------------

See the [CHANGELOG](CHANGELOG.md)

License
-------

See the [MIT LICENSE](LICENSE).
