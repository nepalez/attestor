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
      def initialize(*items)
        @items = items.flatten
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
        block_given? ? items.each { |item| yield(item) } : to_enum
      end

      # Returns validators used in given context
      #
      # @param  [#to_sym] context
      #
      # @return [Attestor::Validators]
      def set(context)
        validators = select { |item| item.used_in_context? context }
        (validators == items) ? self : self.class.new(validators)
      end

      # Returns validators updated by a new validator with given args
      #
      # @param  [Array] args
      #
      # @return [Attestor::Validators]
      def add_validator(*args)
        add_item Validator, *args
      end

      # Returns validators updated by a new follower with given args
      #
      # @param  [Array] args
      #
      # @return [Attestor::Validators]
      def add_follower(*args)
        add_item Follower, *args
      end

      private

      attr_reader :items

      def add_item(type, *args)
        item = type.new(*args)
        include?(item) ? self : self.class.new(items, item)
      end

    end # class Validators

  end # module Validations

end # module Attestor
