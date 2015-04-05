# encoding: utf-8

module Attestor

  module Validations

    # @private
    module Reporter

      def validate(object)
        validate! object
        Report.new(object)
      rescue InvalidError => error
        Report.new(error.object, error)
      end

    end # module Reporter

  end # module Validations

end # module Attestor
