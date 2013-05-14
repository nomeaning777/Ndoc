# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ndoc/version'

Gem::Specification.new do |spec|
  spec.name          = "ndoc"
  spec.version       = Ndoc::VERSION
  spec.authors       = ["nomeaning"]
  spec.email         = ["nomeaning@mma.club.uec.ac.jp"]
  spec.description   = %q{Markup Language like MoinMoin}
  spec.summary       = %q{Markup Language like MoinMoin}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
