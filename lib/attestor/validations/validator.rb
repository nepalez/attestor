# encoding: utf-8

module Attestor

  module Validations

    # @private
    class Validator
      include Reporter

      def initialize(name = :invalid, except: nil, only: nil, &block)
        @name      = name.to_sym
        @whitelist = normalize(only)
        @blacklist = normalize(except)
        @block     = block
        freeze
      end

      attr_reader :name, :whitelist, :blacklist, :block

      def used_in_context?(context)
        symbol = context.to_sym
        whitelisted?(symbol) && !blacklisted?(symbol)
      end

      def validate!(object)
        block ? object.instance_eval(&block) : object.__send__(name)
      end

      private

      def whitelisted?(symbol)
        whitelist.empty? || whitelist.include?(symbol)
      end

      def blacklisted?(symbol)
        blacklist.include? symbol
      end

      def normalize(list)
        Array(list).map(&:to_sym).uniq
      end

    end # class Validator

  end # module Validations

end # module Attestor
