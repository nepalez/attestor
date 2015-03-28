# encoding: utf-8

module Attestor

  # The exception to be raised when a validation fails
  class InvalidError < RuntimeError

    # @!scope class
    # @!method new(object, messages = nil)
    # Creates an exception for given object
    #
    # @param  [Object] object
    #   The invalid object
    # @param [String, Array<String>] messages
    #   The list of validation error messages
    #
    # @return [Attestor::InvalidError]

    # @private
    def initialize(object, messages = nil)
      @object   = object
      @messages = Array(messages)
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
