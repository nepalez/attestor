# encoding: utf-8

module Attestor

  module Validations

    # @private
    class Context

      attr_accessor :klass, :options

      def initialize(klass, options)
        self.klass   = klass
        self.options = options
      end

      def validate(name = nil, &block)
        klass.validate(name, options, &block)
      end

      def validates(name = nil, &block)
        klass.validates(name, options, &block)
      end

    end # class Context

  end # module Validations

end # module Attestor
