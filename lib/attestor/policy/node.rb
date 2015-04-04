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

      private

      def any_valid?
        detect { |item| item.validate.valid? }
      end

      def any_invalid?
        detect { |item| item.validate.invalid? }
      end

    end # class Node

  end # module Base

end # module Policy
