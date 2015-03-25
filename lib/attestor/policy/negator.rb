# encoding: utf-8

module Attestor

  module Policy

    # Composes a policy with an argument of its {#not} method
    #
    # @api private
    class Negator

      # @!scope class
      # @!method new(policy, composer)
      # Creates the negator object, expecting {#not} method call
      #
      # @param [Policy::Base] policy
      #   the policy to be composed with negations of other policies
      # @param [Class] composer
      #   the composer for policies
      #
      # @return [Policy::Base::Negator]
      def initialize(composer, policy)
        @policy   = policy
        @composer = composer
        freeze
      end

      # Returns a composition of the {#policy} with negations of other policies
      #
      # @param [Policy::Base, Array<Policy::Base>] policies
      #
      # @return [Policy::Base]
      def not(*policies)
        composer.new policy, policies.flat_map(&Not.method(:new))
      end

      # @!attribute [r] policy
      # The the policy to be composed with negations of other policies
      #
      # @return [Policy::Base]
      attr_reader :policy

      # @!attribute [r] composer
      # The the composer for policies
      #
      # @return [Class]
      attr_reader :composer

    end # class Negator

  end # module Policy

end # module Attestor
