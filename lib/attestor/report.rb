# encoding: utf-8

module Attestor

  # Describes the result, returned by safe validation
  class Report

    # @private
    def initialize(object, error = nil)
      @object = object
      @error  = error
      freeze
    end

    # @!attribute [r] object
    # The object being validated
    #
    # @return [Object]
    attr_reader :object

    # @!attribute [r] error
    # The exception raised by validation
    #
    # @return [Attestor::InvalidError] if validation fails
    # @return [nil] if validation passes
    attr_reader :error

    # Checks whether validation passes
    #
    # @return [Boolean]
    def valid?
      error.blank?
    end

    # Checks whether validation fails
    #
    # @return [Boolean]
    def invalid?
      !valid?
    end

    # Returns the list of error messages
    #
    # @return [Array<String>]
    def messages
      error ? error.messages : []
    end

  end # class Report

end # module Attestor
