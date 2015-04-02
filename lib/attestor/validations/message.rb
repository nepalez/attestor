# encoding: utf-8

module Attestor

  module Validations

    # @private
    class Message < String

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
