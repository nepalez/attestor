# encoding: utf-8

module Attestor

  # API for objects to be validated
  module Validations

    # Calls all validations used in the selected context
    #
    # @raise [Attestor::Validations::InvalidError] if validations fail
    # @raise [NoMethodError] if some of validations are not implemented
    #
    # @return [undefined]
    def validate(context = :all)
      self.class.validations.set(context).each(&method(:__send__))
    end

    # Raises InvalidError with a corresponding message
    #
    # @overload invalid(name, options = {})
    #
    #   @param [Symbol] name
    #     the name of the error
    #   @param [Hash] options
    #     the options for symbolic name translation
    #
    #   @return [String]
    #     translation of symbolic name in the current object's scope
    #
    # @overload invalid(name)
    #
    #   @param [#to_s] name
    #     the error message (not a symbol)
    #
    #   @return [String]
    #     the name converted to string
    def invalid(name, options = {})
      message = Message.new(name, self, options)
      fail InvalidError.new self, [message]
    end

    # @private
    module ClassMethods

      # Returns a collection of items describing applied validations
      #
      # @return [Attestor::Collection]
      #
      # @api private
      def validations
        @validations ||= Collection.new
      end

      # Adds an item to {#validations}
      #
      # Mutates the class by changing its {#validations} attribute!
      #
      # @param [#to_sym] name
      # @param [Hash] options
      # @option options [#to_sym, Array<#to_sym>] :except
      #   the black list of contexts for validation
      # @option options [#to_sym, Array<#to_sym>] :only
      #   the white list of contexts for validation
      #
      # @return [Attestor::Collection] the updated collection
      def validate(name, options = {})
        @validations = validations.add(name, options)
      end

    end # module ClassMethods

    # @private
    def self.included(klass)
      klass.instance_eval { extend ClassMethods }
    end

    # @!parse extend Attestor::Validations::ClassMethods

  end # module Validations

end # module Attestor
