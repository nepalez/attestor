$:.push File.expand_path("../lib", __FILE__)
require "attestor/version"

Gem::Specification.new do |gem|

  gem.name        = "attestor"
  gem.version     = Attestor::VERSION.dup
  gem.author      = "Andrew Kozin"
  gem.email       = "andrew.kozin@gmail.com"
  gem.homepage    = "https://github.com/nepalez/attestor"
  gem.summary     = "Validations for immutable Ruby objects"
  gem.description = gem.summary
  gem.license     = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = Dir["spec/**/*.rb"]
  gem.extra_rdoc_files = Dir["README.md", "LICENSE"]
  gem.require_paths    = ["lib"]

  gem.required_ruby_version = "~> 2.0"
  gem.add_runtime_dependency "extlib", "~> 0.9"
  gem.add_development_dependency "hexx-rspec", "~> 0.4"

end # Gem::Specification
