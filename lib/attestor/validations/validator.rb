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
        generate_id
        freeze
      end

      attr_reader :name

      def ==(other)
        other.instance_of?(self.class) ? id.equal?(other.id) : false
      end

      def used_in_context?(context)
        symbol = context.to_sym
        whitelisted?(symbol) && !blacklisted?(symbol)
      end

      def validate!(object)
        block ? object.instance_eval(&block) : object.__send__(name)
      end

      protected

      attr_reader :id

      private

      attr_reader :whitelist, :blacklist, :block

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
