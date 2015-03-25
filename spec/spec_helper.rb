# encoding: utf-8
require "hexx-rspec"

begin
  require "hexx-suit"
rescue LoadError
  false
end

# Loads runtime metrics
Hexx::RSpec.load_metrics_for(self)

# Loads the code under test
require "attestor"
