# encoding: utf-8

module Attestor

  module Policy

    # XOR-concatenation of several policies (branches)
    #
    # The policy is valid when it has both valid and invalid branches.
    #
    # @example (see #validate)
    #
    # @api private
    class Xor < Node

      # Checks whether both valid and invalid branches are present
      #
      # @example
      #   first.valid?  # => true
      #   second.valid? # => true
      #
      #   composition = Attestor::Policy::Xor.new(first, second)
      #   composition.validate
      #   # => Policy::InvalidError
      #
      # @return [undefined]
      def validate
        return if any_valid? && any_invalid?
        super
      end

    end # class Xor

  end # module Base

end # module Policy
