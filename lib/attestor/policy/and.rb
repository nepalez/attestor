# encoding: utf-8

module Attestor

  module Policy

    # @private
    class And < Node

      def validate!
        return unless detect(&:invalid?)
        super
      end

    end # class And

  end # module Base

end # module Policy
