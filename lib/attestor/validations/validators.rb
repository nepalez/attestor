# encoding: utf-8

module Attestor

  module Validations

    # @private
    class Validators
      include Enumerable
      include Reporter

      def initialize(*items)
        @items = items.flatten
        freeze
      end

      def each
        block_given? ? items.each { |item| yield(item) } : to_enum
      end

      def set(context)
        self.class.new select { |item| item.used_in_context? context }
      end

      def add_validator(*args, &block)
        self.class.new items, Validator.new(*args, &block)
      end

      def add_delegator(*args, &block)
        self.class.new items, Delegator.new(*args, &block)
      end

      def validate!(object)
        results = errors(object)
        return if results.empty?
        fail InvalidError.new object, results.map(&:messages).flatten
      end

      private

      attr_reader :items

      def errors(object)
        items.map { |validator| validator.validate(object) }.select(&:invalid?)
      end

    end # class Validators

  end # module Validations

end # module Attestor
