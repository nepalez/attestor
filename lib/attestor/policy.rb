# encoding: utf-8

module Attestor

  # API for policies that validate another objects
  module Policy
    # @!parse include Attestor::Validations
    # @!parse extend Attestor::Validations::ClassMethods
    # @!parse extend Attestor::Policy::Factory

    # @private
    def self.included(klass)
      klass.instance_eval do
        include Validations
        extend Factory
      end
    end

    # Builds a policy class with given attributes
    #
    # @example
    #   MyPolicy = Attestor::Policy.new(:foo, :bar) do
    #     attr_reader :baz
    #   end
    #
    # @param [Array<#to_sym>] attributes
    # @param [Proc] block
    #
    # @yield the block in the scope of created class
    #
    # @return [Class] the policy class, based on Struct
    def self.new(*attributes, &block)
      Struct.new(*attributes) do
        include Policy
        class_eval(&block) if block_given?
      end
    end

    # Negates the current policy
    #
    # @return [Attestor::Policy::Not]
    def not
      self.class.not(self)
    end

    # Builds the AND composition of current policy with other policies
    #
    # @overload and(policy, *others)
    #   Combines the policy with the others
    #
    #   The combination is valid if all policies are valid
    #
    #   @param [Attestor::Policy, Array<Attestor::Policy>] others
    #
    #   @return [Attestor::Policy::And]
    #
    # @overload and(policy)
    #   Creates a negator object, awaiting fot #not method call
    #
    #   @example
    #     policy.and.not(one, two)
    #
    #     # this is equal to combination with negation of other policies:
    #     policy.and(one.not, two.not)
    #
    #   @return [Attestor::Policy::Negator]
    def and(*others)
      self.class.and(self, *others)
    end

    # Builds the OR composition of current policy with other policies
    #
    # @overload or(policy, *others)
    #   Combines the policy with the others
    #
    #   The combination is valid unless all the policies are invalid
    #
    #   @param [Attestor::Policy, Array<Attestor::Policy>] others
    #
    #   @return [Attestor::Policy::And]
    #
    # @overload or(policy)
    #   Creates a negator object, awaiting fot #not method call
    #
    #   @example
    #     policy.or.not(one, two)
    #
    #     # this is equal to combination with negation of other policies:
    #     policy.or(one.not, two.not)
    #
    #   @return [Attestor::Policy::Negator]
    def or(*others)
      self.class.or(self, *others)
    end

    # Builds the XOR composition of current policy with other policies
    #
    # @overload xor(policy, *others)
    #   Combines the policy with the others
    #
    #   The combination is valid if both valid and invalid policies are present
    #
    #   @param [Attestor::Policy, Array<Attestor::Policy>] others
    #
    #   @return [Attestor::Policy::And]
    #
    # @overload xor(policy)
    #   Creates a negator object, awaiting fot #not method call
    #
    #   @example
    #     policy.xor.not(one, two)
    #
    #     # this is equal to combination with negation of other policies:
    #     policy.xor(one.not, two.not)
    #
    #   @return [Attestor::Policy::Negator]
    def xor(*others)
      self.class.xor(self, *others)
    end

  end # module Policy

end # module Attestor
