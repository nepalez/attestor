# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Xor < Node

      def validate!
        return if detect(&:valid?) && detect(&:invalid?)
        super
      end

    end # class Xor

  end # module Base

end # module Policy
