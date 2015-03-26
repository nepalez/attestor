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

Instead of collecting errors inside the object, the module's `validate` instance method just raises an exception (`Attestor::InvalidError`), that carries errors outside of the object. The object stays untouched (and can be made immutable).

So to speak, validation just attests at the object and complains loudly when things goes wrong.

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

`Attestor::Validations` API consists of 1 class method `.validate` and 2 instance methods (`validate` and `invalid`).

Declare validation in the same way as ActiveModel's `.validate` method does:

```ruby
class Transfer < Struct.new(:debet, :credit)
  include Attestor::Validations

  validate :consistent
end
```

You have to define an instance validator method (that can be private):

```ruby
class Transfer < Struct.new(:debet, :credit)
  # ...

  private

  def consistent
    fraud = credit.sum - debet.sum
    invalid :inconsistent, fraud: fraud if fraud != 0
  end
end
```

The `#invalid` method translates its argument in a current class scope and raises an exception.

```ruby
# config/locales/en.yml
en:
  attestor:
    errors:
      transfer:
        inconsistent: "Credit differs from debet by %{fraud}"
```

To run validations use the `#validate` instance method:

```ruby
debet  = OpenStruct.new(sum: 100)
credit = OpenStruct.new(sum: 90)
fraud_transfer = Transfer.new(debet, credit)

begin
  transfer.validate
rescue => error
  error.object == transfer # => true
  error.messages
  # => ["Credit differs from debet by 10"]
end
```

Adding Contexts
---------------

Sometimes you need to validate the object agaist the subset of validations, not all of them.

To do this use `:except` and `:only` options of the `.validate` class method.

```ruby
class Transfer < Struct.new(:debet, :credit)
  include Attestor::Validations

  validate :consistent, except: :steal_of_money
end
```

Then call a validate method with that context:

```ruby
fraud_transfer.validate                 # => InvalidError
fraud_transfer.validate :steal_of_money # => PASSES!
```

Just as the `:except` option blacklists validations, the `:only` method whitelists them:

```ruby
class Transfer < Struct.new(:debet, :credit)
  include Attestor::Validations

  validate :consistent, only: :fair_trade
end

fraud_transfer.validate             # => PASSES
fraud_transfer.validate :fair_trade # => InvalidError
```

Policy Objects
--------------

Extract a validator to the separate object (policy). Basically the policy includes `Attestor::Validations` with additional methods.

```ruby
class ConsistencyPolicy < Struct.new(:debet, :credit)
  include Attestor::Policy

  validate :consistent

  private

  def consistent
    fraud = credit - debet
    invalid :inconsistent, fraud: fraud if fraud != 0
  end
end
```

This looks mainly the same as before. But the policy's debet and credit are numbers, not the transactions. **The policy knows nothing about the nature of its attributes** - whether they are sums of transactions, or anything else.

This is the core part of the [Policy Object design pattern] - it isolates the rule from unsignificant details of the target.

From the other hand, the target needs to know nothing about how the policy works with data:

```ruby
class Transfer < Struct.new(:debet, :credit)
  include Attestor::Validations

  validate :constistent

  private

  def consistent
    policy = ConsistencyPolicy.new(debet.sum, credit.sum)
    invalid :inconsistent if policy.invalid?
  end
end
```

The "new" method `valid?` just returns true or false, trowing error messages out as unsignificant details.

If you need messages from policy, you can use `validate` method and capture its exception. But should you?! Instead you'd better to provie the message, that makes sense in the Transfer context.

[Policy Object design pattern]: http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/

Complex Policies
----------------

Now that we isolated policies, we can provide complex policies from simpler ones.

Suppose we have two policy objects:

```ruby
valid_policy.valid?   # => true
invalid_policy.valid? # => false
```

Use `Policy` factory methods to provide compositions:

```ruby
complex_policy = valid_policy.not
complex_policy.validate # => fails

complex_policy = valid_policy.and(valid_policy, invalid_policy)
complex_policy.validate # => fails

complex_policy = invalid_policy.or(invalid_policy, valid_policy)
complex_policy.validate # => passes

complex_policy = valid_policy.xor(valid_poicy, valid_policy)
complex_policy.validate # => fails

complex_policy = valid_policy.xor(valid_poicy, invalid_policy)
complex_policy.validate # => passes
```

The `or`, `and` and `xor` methods, called without argument(s), don't provide a policy object. They return lazy composer, expecting `#not` method.

```ruby
complex_policy = valid_policy.and.not(invalid_policy, invalid_policy)
# this is the same as:
valid_policy.and(invalid_policy.not, invalid_policy.not)
```

If you prefer wrapping to chaining, use the `Policy` factory methods instead:

```ruby
Policy.and(valid_policy, invalid_policy)
# this is the same as: valid_policy.and invalid_policy

Policy.or(valid_policy, invalid_policy)
# this is the same as: valid_policy.or invalid_policy

Policy.xor(valid_policy, invalid_policy)
# this is the same as: valid_policy.xor invalid_policy

Policy.not(valid_policy)
# this is the same as: valid_policy.not
```

As before, you can use any number of policies (except for negation of a single policy) at any number of nesting.

This can be used either in targets or in complex policies. In the later case do it like this:

```ruby
class ComplexPolicy < Struct.new(:a, :b, :c)
  include Attestor::Policy

  validate :complex_rule

  private

  def complex_rule
    first_policy  = FirstPolicy.new(a, b)
    second_policy = SecondPolicy.new(b, c)

    invalid :base unless first_policy.xor(second_policy).valid?
  end
end
```

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
