# frozen_string_literal: true

$LOAD_PATH.push(File.expand_path('lib', __dir__))

require 'doorkeeper/device_authorization_grant/version'

Gem::Specification.new do |spec|
  spec.name        = 'doorkeeper-device_authorization_grant'
  spec.version     = Doorkeeper::DeviceAuthorizationGrant::VERSION
  spec.authors     = ['EXOP Group']
  spec.email       = ['opensource@exop-group.com']
  spec.homepage    = 'https://github.com/exop-group/doorkeeper-device_authorization_grant'
  spec.summary     = 'OAuth 2.0 Device Authorization Grant extension for Doorkeeper.'
  spec.description = 'OAuth 2.0 Device Authorization Grant extension for Doorkeeper.'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'doorkeeper', '~> 5.4'

  spec.add_development_dependency 'rubocop', '~> 1.8'
  spec.add_development_dependency 'rubocop-rails', '~> 2.9.1'
  spec.add_development_dependency 'simplecov', '~> 0.21.1'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'
  spec.add_development_dependency 'yard', '~> 0.9.26'
end
