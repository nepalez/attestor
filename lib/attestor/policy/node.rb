# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Node
      include Attestor::Policy, Enumerable

      def initialize(*branches)
        @branches = branches.flatten
        freeze
      end

      attr_reader :branches

      def validate!
        invalid :base
      end

      def each
        block_given? ? branches.each { |item| yield(item) } : to_enum
      end

    end # class Node

  end # module Base

end # module Policy
