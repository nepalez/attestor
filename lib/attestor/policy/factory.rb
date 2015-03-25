# encoding: utf-8

module Attestor

  module Policy

    # The collection of factory methods for creating complex policies
    module Factory

      # Builds the AND composition of policy with other policies
      #
      # @param [Attestor::Policy] policy
      #
      # @overload and(policy, *others)
      #   Combines a policy with others
      #
      #   @param [Attestor::Policy, Array<Attestor::Policy>] others
      #
      #   @return [Attestor::Policy::And]
      #
      # @overload and(policy)
      #   Creates a negator object, awaiting fot #not method call
      #
      #   @return [Attestor::Policy::Negator]
      def and(policy, *others)
        __factory_method__(And, policy, others)
      end

      # Builds the OR composition of policy with other policies
      #
      # @param [Attestor::Policy] policy
      #
      # @overload or(policy, *others)
      #   Combines a policy with others
      #
      #   @param [Attestor::Policy, Array<Attestor::Policy>] others
      #
      #   @return [Attestor::Policy::Or]
      #
      # @overload or(policy)
      #   Creates a negator object, awaiting fot #not method call
      #
      #   @return [Attestor::Policy::Negator]
      def or(policy, *others)
        __factory_method__(Or, policy, others)
      end

      # Builds the XOR composition of policy with other policies
      #
      # @param [Attestor::Policy] policy
      #
      # @overload xor(policy, *others)
      #   Combines a policy with others
      #
      #   @param [Attestor::Policy, Array<Attestor::Policy>] others
      #
      #   @return [Attestor::Policy::Xor]
      #
      # @overload xor(policy)
      #   Creates a negator object, awaiting fot #not method call
      #
      #   @return [Attestor::Policy::Negator]
      def xor(policy, *others)
        __factory_method__(Xor, policy, others)
      end

      # Builds the negation of given policy
      #
      # @param [Attestor::Policy] policy
      #
      # @return [Attestor::Policy::Not]
      def not(policy)
        Not.new(policy)
      end

      private

      def __factory_method__(composer, policy, others)
        policies = others.flatten
        return composer.new(policy, policies) if policies.any?
        Negator.new(composer, policy)
      end

    end # module Factory

  end # module Policy

end # module Attestor
