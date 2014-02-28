# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trireme/version'

Gem::Specification.new do |spec|
  spec.name          = "trireme"
  spec.version       = Trireme::VERSION
  spec.authors       = ["Nathan Sharpe"]
  spec.email         = ["nathan@cliftonlabs.com"]
  spec.description   = %q{Rails application generator}
  spec.summary       = %q{Generates rails application and configures some extras}
  spec.homepage      = "https://github.com/cliftonlabs/trireme"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0"
end
