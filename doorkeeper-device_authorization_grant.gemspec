# frozen_string_literal: true

require_relative 'lib/doorkeeper/device_authorization_grant/version'

Gem::Specification.new do |spec|
  spec.name        = 'doorkeeper-device_authorization_grant'
  spec.version     = Doorkeeper::DeviceAuthorizationGrant::VERSION
  spec.authors     = ['EXOP Group']
  spec.email       = ['opensource@exop-group.com']
  spec.homepage    = 'https://github.com/exop-group/doorkeeper-device_authorization_grant'
  spec.summary     = 'OAuth 2.0 Device Authorization Grant extension for Doorkeeper.'
  spec.description = 'OAuth 2.0 Device Authorization Grant extension for Doorkeeper.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'doorkeeper', '~> 5.5'

  spec.add_development_dependency 'rubocop', '~> 1.23'
  spec.add_development_dependency 'rubocop-rails', '~> 2.12'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'yard', '~> 0.9.27'
end
