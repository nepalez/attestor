# encoding: utf-8

module Attestor

  # API for objects to be validated
  module Validations

    # Calls all validators for given context
    #
    # @param [#to_sym] context
    #
    # @raise [Attestor::Validations::InvalidError] if validators fail
    # @raise [NoMethodError] if some of validators are not implemented
    #
    # @return [undefined]
    def validate!(context = :all)
      self.class.validators.set(context).validate! self
    end

    # Calls all validators for given context and return validation results
    #
    # @param (see #validate!)
    #
    # @return [undefined]
    def validate(context = :all)
      self.class.validators.set(context).validate self
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
      fail InvalidError.new self, message
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

      # @!method validate(name = nil, except: nil, only: nil, &block)
      # Uses an instance method or block for validation
      #
      # Mutates the class by changing its {#validators} attribute!
      #
      # @option options [#to_sym, Array<#to_sym>] :except
      #   the black list of contexts for validation
      # @option options [#to_sym, Array<#to_sym>] :only
      #   the white list of contexts for validation
      #
      # @overload validate(name, except: nil, only: nil)
      #   Uses the instance method for validation
      #
      #   @param [#to_sym] name The name of the instance method
      #
      # @overload validate(except: nil, only: nil, &block)
      #   Uses the block (in the scope of the instance) for validation
      #
      #   @param [Proc] block
      #
      # @return [Attestor::Validators] the updated list of validators
      def validate(*args, &block)
        @validators = validators.add_validator(*args, &block)
      end

      # @!method validates(name = nil, except: nil, only: nil, &block)
      # Delegates a validation to instance method or block
      #
      # Mutates the class by changing its {#validators} attribute!
      #
      # @option (see #validate)
      #
      # @overload validates(name, except: nil, only: nil)
      #   Delegates a validation to instance method
      #
      #   @param [#to_sym] name
      #     The name of the instance method that should respond to #validate
      #
      # @overload validates(except: nil, only: nil, &block)
      #   Uses the block (in the scope of the instance) for validation
      #
      #   @param [Proc] block
      #     The block that should respond to #validate
      #
      # @return (see #validate)
      def validates(*args, &block)
        @validators = validators.add_delegator(*args, &block)
      end

      # Groups validations assigned to shared context
      #
      # @example
      #   validations only: :foo do
      #     validates :bar
      #     validate  { invalid :foo unless baz }
      #   end
      #
      #   # this is equal to:
      #
      #   validates :bar, only: :foo
      #   validate  { invalid :foo unless baz }, only: :foo
      #
      # @param [Hash] options
      # @param [Proc] block
      #
      # @return [undefined]
      def validations(**options, &block)
        Context.new(self, options).instance_eval(&block) if block_given?
      end

    end # module ClassMethods

    # @private
    def self.included(klass)
      klass.instance_eval { extend ClassMethods }
    end

    # @!parse extend Attestor::Validations::ClassMethods

  end # module Validations

end # module Attestor
