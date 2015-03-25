# encoding: utf-8

module Attestor

  # API for policies that validates another objects
  module Policy
    # @!parse include Attestor::Validations
    # @!parse extend Attestor::Validations::ClassMethods
    # @!parse extend Attestor::Policy::Factory

    # @private
    def self.included(klass)
      klass.instance_eval do
        include Validations
      end
    end

    # Checks whether the policy is valid
    #
    # @return [Boolean]
    def valid?
      validate
    rescue InvalidError
      false
    else
      true
    end

    # Checks whether the policy is invalid
    #
    # @return [Boolean]
    def invalid?
      !valid?
    end

  end # module Policy

end # module Attestor
