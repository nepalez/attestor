# encoding: utf-8

require "extlib"

require_relative "attestor/version"

require_relative "attestor/invalid_error"

require_relative "attestor/validations"
require_relative "attestor/validations/item"
require_relative "attestor/validations/collection"
require_relative "attestor/validations/message"

require_relative "attestor/policy"
require_relative "attestor/policy/node"
require_relative "attestor/policy/and"
require_relative "attestor/policy/or"
require_relative "attestor/policy/xor"
require_relative "attestor/policy/not"
require_relative "attestor/policy/negator"

# Namespace for the code of the 'attestor' gem
module Attestor

end # module Attestor
