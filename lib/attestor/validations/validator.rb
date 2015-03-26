# encoding: utf-8

module Attestor

  module Validations

    # Describe a validator for class instances
    #
    # @example
    #   validator = Validator.new(:foo, policy: :bar, only: :baz)
    #
    #   validator.used_in_context? :baz # => true
    #   validator.validate object
    #
    # @api private
    class Validator

      # @!scope class
      # @!method new(name, except: [], only: [])
      # Creates a named item with blacklist or whitelist of contexts
      #
      # @param  [#to_sym] name
      # @option [#to_sym, Array<#to_sym>] :except
      # @option [#to_sym, Array<#to_sym>] :only
      #
      # @return [Attestor::Validations::Validator]

      # @private
      def initialize(name, except: nil, only: nil)
        @name      = name.to_sym
        @whitelist = normalize(only)
        @blacklist = normalize(except)
        generate_id
        freeze
      end

      # @!attribute [r] name
      # The name of the item
      #
      # @return [Symbol]
      attr_reader :name

      # Compares an item to another one
      #
      # @param [Object] other
      #
      # @return [Boolean]
      def ==(other)
        other.instance_of?(self.class) ? id.equal?(other.id) : false
      end

      # Checks if the item should be used in given context
      #
      # @param [#to_sym] context
      #
      # @return [Boolean]
      def used_in_context?(context)
        symbol = context.to_sym
        whitelisted?(symbol) && !blacklisted?(symbol)
      end

      protected

      # @!attribute [r] id
      # The item's identity
      #
      # @return [String]
      attr_reader :id

      private

      attr_reader :whitelist, :blacklist

      def whitelisted?(symbol)
        whitelist.empty? || whitelist.include?(symbol)
      end

      def blacklisted?(symbol)
        blacklist.include? symbol
      end

      def generate_id
        @id = [name, whitelist, blacklist].hash
      end

      def normalize(list)
        Array(list).map(&:to_sym).uniq
      end

    end # class Validator

  end # module Validations

end # module Attestor
