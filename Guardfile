# encoding: utf-8

guard :rspec, cmd: "bundle exec rspec" do

  watch(%r{^lib/attestor/(.+)\.rb$}) do |m|
    "spec/tests/#{ m[1] }_spec.rb"
  end

  watch(%r{^spec/tests/.+_spec.rb})

  watch("lib/*.rb")             { "spec" }
  watch("spec/spec_helper.rb")  { "spec" }
  watch("spec/support/**/*.rb") { "spec" }

end # guard :rspec
