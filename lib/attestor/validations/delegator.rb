# encoding: utf-8

module Attestor

  module Validations

    # Describe a validator that delegates validation to instance method or block
    #
    # The follower not only calls an instance method (block) as validator does,
    # but calls #validate method of the result.
    #
    # @example
    #   follower = Validator.new(:foo, only: :baz) { FooPolicy.new(foo) }
    #
    # @api private
    class Delegator < Validator

      # Validates an object by delegation
      #
      # @param [Object] object
      #
      # @raise [Attestor::InvalidError] if a policy isn't valid
      #
      # @return [undefined]
      def validate(_)
        super.validate
      end

    end # class Follower

  end # module Validations

end # module Attestor
