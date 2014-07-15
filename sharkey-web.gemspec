# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sharkey/version'

Gem::Specification.new do |spec|
  spec.name          = 'sharkey-web'
  spec.version       = Sharkey::VERSION
  spec.authors       = ["Alexandre Dantas"]
  spec.email         = ["eu@alexdantas.net"]
  spec.summary       = "Misterious project"
  spec.description   = <<END
This is a misterious project.

Deal with it.
END

  spec.homepage      = "https://github.com/alexdantas/sharkey/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.0'

  # Note that the system MUST HAVE sqlite3 and libsqlite3-dev
  spec.add_dependency 'sinatra', '>= 1.2.1'
  spec.add_dependency 'slim'
  spec.add_dependency 'data_mapper'
  spec.add_dependency 'dm-types'
  spec.add_dependency 'dm-sqlite-adapter'
  spec.add_dependency 'chronic_duration'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'metainspector'
  spec.add_dependency 'vegas'
  spec.add_dependency 'redcarpet'

  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'shotgun'
end

