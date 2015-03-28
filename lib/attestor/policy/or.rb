# encoding: utf-8

module Attestor

  module Policy

    # OR-concatenation of several policies (branches)
    #
    # The policy is valid unless all its branches are invalid.
    #
    # @example (see #validate)
    #
    # @api private
    class Or < Node

      # Checks whether any policy is valid
      #
      # @example
      #   first.valid?  # => false
      #   second.valid? # => false
      #
      #   composition = Attestor::Policy::Or.new(first, second)
      #   composition.validate
      #   # => Policy::InvalidError
      #
      # @return [undefined]
      def validate
        return if detect(&:valid?)
        super
      end

    end # class Or

  end # module Base

end # module Policy
