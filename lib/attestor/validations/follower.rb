# encoding: utf-8

module Attestor

  module Validations

    # Describe a policy follower for class instances
    #
    # The follower not only calls an instance method (as validator does),
    # but checks whether the result is valid and raises an exception otherwise.
    #
    # @example
    #   follower = Validator.new(:foo, only: :baz) { FooPolicy.new(foo) }
    #
    # @api private
    class Follower < Validator

      # Validates a policy
      #
      # @param [Object] object
      #
      # @raise [Attestor::InvalidError] if a policy isn't valid
      #
      # @return [undefined]
      def validate(object)
        policy = super(object)
        return if policy.valid?
        object.__send__ :invalid, name
      end

    end # class Follower

  end # module Validations

end # module Attestor
