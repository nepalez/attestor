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
* `validate` - the safe version of `validate!`. It rescues an exception and returns special result object, that carries error info outside of the object.

The object stays untouched (and can be made immutable).

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

Basic Use
----------

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

Alternatively, you can describe validation in the block (called in the scope of instance):

```ruby
class Transfer
  # ...
  validate { invalid :inconsistent if credit.sum != debet.sum }
end
```

The `#invalid` method translates its argument in a current class scope and raises an exception with that method.

```yaml
# config/locales/en.yml
---
en:
  attestor:
    errors:
      transfer:
        inconsistent: "Credit differs from debet by %{fraud}"
```

To run validations use the `#validate!` instance method:

```ruby
debet  = OpenStruct.new(sum: 100)
credit = OpenStruct.new(sum: 90)
fraud_transfer = Transfer.new(debet, credit)

begin
  transfer.validate!
rescue Attestor::InvalidError => error
  error.object == transfer # => true
  error.messages           # => ["Credit differs from debet by 10"]
end
```

Another option is to use the safe version `#validate`. It rescues from the exception and returns results as a separate object:

```ruby
result = transfer.validate!

result.valid?               # => false
result.invalid?             # => true
result.object == transfer   # => true
result.messages             # => ["Credit differs from debet by 10"]
result.error                # => <Attestor::InvalidError ...>
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

You can use the same validator several times with different contexts.

```ruby
class Transfer
  # ...

  # validate :consistent, only: [:fair_trade, :legal]
  validate :consistent, only: :fair_trade
  validate :consistent, only: :legal

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

Then use `validates` helper:

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

The difference between `.validate :something` and `.validates :something` class methods is that:
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

They also respond to `valid?` and `invalid?` methods (that rescue from `vaidate` missing any error messages).

Complex Policies
----------------

Policies (assertions) can be combined by logical methods.

Suppose we have two policy objects:

```ruby
valid_policy.valid?   # => true
invalid_policy.valid? # => false
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

Compatibility
-------------

Tested under rubies compatible to rubies with API 2.0+:

* MRI 2.0+
* Rubinius-2 (mode 2.0)
* JRuby 9000+ (mode 2.0+)

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

[RSpec]: http://rspec.info
[hexx-suit]: https://github.com/nepalez/hexx-suit

Contributing
------------

* Fork the project.
* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE).
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version
  in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See the [MIT LICENSE](LICENSE).
