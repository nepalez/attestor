# encoding: utf-8

module Attestor

  module Validations

    # The collection of validations used by class instances
    #
    # @api private
    class Collection
      include Enumerable

      # @!scope class
      # @!method new(items = [])
      # Creates an immutable collection with optional list of items
      #
      # @param [Array<Attestor::Collection::Item>] items
      #
      # @return [Attestor::Collection]

      # @private
      def initialize(items = [])
        @items = items
        freeze
      end

      # Iterates through the collection
      #
      # @yield the block
      # @yieldparam [Attestor::Collection::Item] item
      #   items from the collection
      #
      # @return [Enumerator]
      def each
        return to_enum unless block_given?
        items.map(&:name).uniq.each { |item| yield(item) }
      end

      # Returns the collection, updated with new item
      #
      # @param  [#to_sym] name
      # @param  [Hash] options
      # @option options [Array<#to_sym>] :except
      # @option options [Array<#to_sym>] :only
      #
      # @return [Attestor::Collection]
      def add(name, options = {})
        item = Item.new(name, options)
        return self if items.include? item

        self.class.new(items + [item])
      end

      # Returns the collection of items used in given context
      #
      # @param  [#to_sym] context
      #
      # @return [Attestor::Collection]
      def set(context)
        collection = items.select { |item| item.used_in_context? context }

        self.class.new(collection)
      end

      private

      attr_reader :items

    end # class Collection

  end # module Validations

end # module Attestor
