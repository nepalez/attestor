# encoding: utf-8

module Attestor

  module Validations

    # The collection of validations used by class instances
    #
    # @api private
    class Validators
      include Enumerable

      # @!scope class
      # @!method new(items = [])
      # Creates an immutable collection with optional list of items
      #
      # @param [Array<Attestor::Validators::Validator>] items
      #
      # @return [Attestor::Validators]

      # @private
      def initialize(items = [])
        @items = items
        freeze
      end

      # Iterates through the collection
      #
      # @yield the block
      # @yieldparam [Attestor::Validators::Validator] item
      #   items from the collection
      #
      # @return [Enumerator]
      def each
        block_given? ? @items.each { |item| yield(item) } : to_enum
      end

      # Returns validators updated by new item
      #
      # @param  [#to_sym] name
      # @param  [Hash] options
      # @option options [Array<#to_sym>] :except
      # @option options [Array<#to_sym>] :only
      # @option options [Symbol, nil] :policy
      #
      # @return [Attestor::Validators]
      def add(name, options = {})
        item = Validator.new(name, options)
        return self if include? item

        self.class.new(@items + [item])
      end

      # Returns validators used in given context
      #
      # @param  [#to_sym] context
      #
      # @return [Attestor::Validators]
      def set(context)
        validators = select { |item| item.used_in_context? context }

        self.class.new(validators)
      end

      private

      attr_reader :items

    end # class Validators

  end # module Validations

end # module Attestor
