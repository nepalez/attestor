# encoding: utf-8

module Attestor

  module Validations

    # Bulder for error messages
    #
    # @api private
    class Message < String

      # @!scope class
      # @!method new(value, object, options = {})
      # Builds a string from value
      #
      # @param [#to_s] value
      # @param [Object] object
      # @param [Hash] options
      #   options for translating symbolic value
      #
      # @return [String]
      #   either translation of symbolic value or stringified value argument

      # @private
      def initialize(value, object, options = {})
        @value   = value
        @object  = object
        @options = options
        super(@value.instance_of?(Symbol) ? translation : @value.to_s)
        freeze
      end

      private

      def translation
        I18n.t @value, @options.merge(scope: scope, default: default)
      end

      def scope
        %W(attestor errors #{ class_scope })
      end

      def class_scope
        @object.class.to_s.split("::").map(&:snake_case).join("/")
      end

      def default
        "#{ @object } is invalid (#{ @value })"
      end

    end # class Message

  end # module Validations

end # module Attestor
