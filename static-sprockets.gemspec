# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'static-sprockets/version'

Gem::Specification.new do |gem|
  gem.name          = "static-sprockets"
  gem.version       = StaticSprockets::VERSION
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jesse@jessestuart.ca"]
  gem.description   = %q{Static app generator via Sprockets}
  gem.summary       = %q{Static app generator via Sprockets}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rack', '~> 1.0'
  gem.add_runtime_dependency 'rack-putty', '0.0.1'

  gem.add_runtime_dependency 'sass'
  gem.add_runtime_dependency 'sprockets-sass'
  gem.add_runtime_dependency 'sprockets-helpers'
  gem.add_runtime_dependency 'sprockets', '~> 2.0'
  gem.add_runtime_dependency 'sprockets-rainpress'
  gem.add_runtime_dependency 'uglifier'
  gem.add_runtime_dependency 'mimetype-fu'
end
