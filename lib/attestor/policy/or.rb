# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Or < Node

      def validate!
        return if detect(&:valid?)
        super
      end

    end # class Or

  end # module Base

end # module Policy
