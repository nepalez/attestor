# encoding: utf-8

module Attestor

  module Policy

    # AND-concatenation of several policies (branches)
    #
    # The policy is valid if all its branches are valid.
    #
    # @example (see #validate)
    #
    # @api private
    class And < Node

      # Checks whether every policy is valid
      #
      # @example
      #   first.valid?  # => true
      #   second.valid? # => false
      #
      #   composition = Attestor::Policy::And.new(first, second)
      #   composition.validate
      #   # => Policy::InvalidError
      #
      # @return [undefined]
      def validate
        return unless any_invalid?
        super
      end

    end # class And

  end # module Base

end # module Policy
