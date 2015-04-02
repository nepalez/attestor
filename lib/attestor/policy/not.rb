# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Not < Node

      def initialize(_)
        super
      end

      def validate!
        return unless detect(&:valid?)
        super
      end

    end # class And

  end # module Base

end # module Policy
