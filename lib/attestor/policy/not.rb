# encoding: utf-8

module Attestor

  module Policy

    # Negation of a single policy
    #
    # The policy is valid if its only branch is invalid
    #
    # @example (see #validate)
    #
    # @api private
    class Not < Node

      # @!scope class
      # @!method new(policy)
      # Creates the policy negation
      #
      # @param [Array<Policy::Base>] policy
      #
      # @return [Policy::Base::Node]

      # @private
      def initialize(_)
        super
      end

      # Checks whether every policy is valid
      #
      # @example
      #   policy.valid? # => true
      #
      #   composition = Attestor::Policy::Not.new(policy)
      #   composition.validate
      #   # => Policy::InvalidError
      #
      # @return [undefined]
      def validate
        return unless any_valid?
        super
      end

    end # class And

  end # module Base

end # module Policy
