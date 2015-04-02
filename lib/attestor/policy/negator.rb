# encoding: utf-8

module Attestor

  module Policy

    # @private
    class Negator

      def initialize(composer, policy)
        @policy   = policy
        @composer = composer
        freeze
      end

      def not(*policies)
        composer.new policy, policies.flat_map(&Not.method(:new))
      end

      attr_reader :policy, :composer

    end # class Negator

  end # module Policy

end # module Attestor
