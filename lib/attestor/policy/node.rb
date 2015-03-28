# encoding: utf-8

module Attestor

  module Policy

    # The base class for composite policies
    #
    # @api private
    class Node
      include Attestor::Policy
      include Enumerable

      # @!scope class
      # @!method new(*branches)
      # Creates the node with branches
      #
      # @param [<Attestor::Policy>, Array<Attestor::Policy>] branches
      #
      # @return [Policy::Base::Node]

      # @private
      def initialize(*branches)
        @branches = branches.flatten
        freeze
      end

      # @!attribute [r] branches
      # The branches of the node
      #
      # @return [Array<Policy::Base>]
      attr_reader :branches

      # Validates the policy as invalid
      #
      # To be reloaded by subclasses (And, Or, Xor, Not)
      #
      # @raise [Policy::InvalidError]
      #
      # @return [undefined]
      def validate
        invalid :base
      end

      # Iterates throught branches
      #
      # @return [Enumerator]
      def each
        block_given? ? branches.each { |item| yield(item) } : to_enum
      end

    end # class Node

  end # module Base

end # module Policy
