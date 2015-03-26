# encoding: utf-8

module Attestor

  # API for objects to be validated
  module Validations

    # Calls all validators for given context
    #
    # @raise [Attestor::Validations::InvalidError] if validators fail
    # @raise [NoMethodError] if some of validators are not implemented
    #
    # @return [undefined]
    def validate(context = :all)
      self.class.validators.set(context).each(&method(:__send__))
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

      # Returns a collection of applied validators
      #
      # @return [Attestor::Validators]
      #
      # @api private
      def validators
        @validators ||= Validators.new
      end

      # Adds an item to {#validators}
      #
      # Mutates the class by changing its {#validators} attribute!
      #
      # @param [#to_sym] name
      # @param [Hash] options
      # @option options [#to_sym, Array<#to_sym>] :except
      #   the black list of contexts for validation
      # @option options [#to_sym, Array<#to_sym>] :only
      #   the white list of contexts for validation
      #
      # @return [Attestor::Validators] the updated collection
      def validate(name, options = {})
        @validators = validators.add(name, options)
      end

    end # module ClassMethods

    # @private
    def self.included(klass)
      klass.instance_eval { extend ClassMethods }
    end

    # @!parse extend Attestor::Validations::ClassMethods

  end # module Validations

end # module Attestor
