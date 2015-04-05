# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Node
      include Attestor::Policy, Enumerable

      attr_reader :branches

      def initialize(*branches)
        @branches = branches.flatten
        freeze
      end

      def validate!
        invalid :base
      end

      def each
        block_given? ? branches.each { |item| yield(item.validate) } : to_enum
      end

    end # class Node

  end # module Base

end # module Policy
