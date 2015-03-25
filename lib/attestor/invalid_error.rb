# encoding: utf-8

module Attestor

  # The exception to be raised when a validation fails
  class InvalidError < RuntimeError

    # @!scope class
    # @!method new(object, validations: nil, messages: [], context: :all)
    # Creates an exception for given object
    #
    # @param  [Object] object
    #   The invalid object
    # @option [Array<String>] :messages
    #   The list of validation error messages
    # @option [Symbol] :context
    #   The list of context for validation
    # @option [Array<Symbol>] :validations
    #   The list of all validations that was checked out
    #
    # @return [Attestor::InvalidError]

    # @private
    def initialize(object, messages = [])
      @object   = object
      @messages = messages.dup.freeze
      freeze
    end

    # @!attribute [r] object
    # The invalid object
    #
    # @return [Object]
    attr_reader :object

    # @!attribute [r] messages
    # The list of validation error messages
    #
    # @return [Array<String>]
    attr_reader :messages

  end # class InvalidError

end # module Attestor
