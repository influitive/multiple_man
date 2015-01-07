# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multiple_man/version'

Gem::Specification.new do |spec|
  spec.name          = "multiple_man"
  spec.version       = MultipleMan::VERSION
  spec.authors       = ["Ryan Brunner"]
  spec.email         = ["ryan@influitive.com"]
  spec.description   = %q{MultipleMan syncs changes to ActiveRecord models via AMQP}
  spec.summary       = %q{MultipleMan syncs changes to ActiveRecord models via AMQP}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", '~> 10.1.0'
  spec.add_development_dependency "rspec", '~> 2.14.1'
  spec.add_runtime_dependency     "bunny", '>= 1.2'
  spec.add_runtime_dependency     "activesupport", '>= 3.0'
  spec.add_runtime_dependency     "connection_pool", ">= 1.2"
end
