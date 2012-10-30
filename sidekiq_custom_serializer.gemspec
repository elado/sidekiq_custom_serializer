# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sidekiq_custom_serializer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Elad Ossadon"]
  gem.email         = ["elad@ossadon.com"]
  gem.description   = %q{An extension for Sidekiq that brings custom serialization of arguments such as ActiveRecord instances, classes, modules and custom objects.}
  gem.homepage      = "https://github.com/elado/sidekiq_custom_serializer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sidekiq_custom_serializer"
  gem.require_paths = ["lib"]
  gem.version       = SidekiqCustomSerializer::VERSION

  gem.add_runtime_dependency 'sidekiq'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'actionmailer', '~> 3'
  gem.add_development_dependency 'activerecord', '~> 3'
  gem.add_development_dependency 'sqlite3'
end
