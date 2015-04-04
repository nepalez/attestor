# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Xor < Node

      def validate!
        return if any_valid? && any_invalid?
        super
      end

    end # class Xor

  end # module Base

end # module Policy
