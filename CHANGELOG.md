# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Register this Doorkeeper extension as `device_code` custom OAuth Grant Flow.

### Changed
- Upgrade `doorkeeper` dependency, matching versions `~> 5.5`.
- Use the standard IANA URN value `urn:ietf:params:oauth:grant-type:device_code`
  as grant type for device access token requests. It replaces the previous
  value `device_code`, which was deliberately nonstandard to make it work with
  Doorkeeper versions prior to `5.5`.

  The old `device_code` value still works out of the box with Doorkeeper <= 5.5.1. However, a warning message
  will be printed, and this functionality will be eventually removed in newer Doorkeeper versions.

  An appropriate way to make the device flow work with any nonstandard / custom
  grant type is to simply register your own custom flow, using the strategy
  class `Doorkeeper::Request::DeviceCode` provided by this extension, and enable
  it in Doorkeeper configuration.
  
  For example, you could add the following code to an appropriate place, such
  as an initializer file:
  ```ruby
  Doorkeeper::GrantFlow.register(
    :custom_device_code, # custom name of your choice
    grant_type_matches: 'device_code', # custom grant type value
    grant_type_strategy: Doorkeeper::Request::DeviceCode
  )
  ```
  Then, enable this grant flow in Doorkeeper configuration:
  ```ruby
  Doorkeeper.configure do
    # ...

    grant_flows [
      'custom_device_code', # name of your custom flow, as registered above
      'device_code', # also enable the default/standard flow, if you want
      # ...
    ]
  
    # ...
  end
  ```
- Update generated files according to the boilerplate from rails `6.1.3.1`.
- Upgrade development dependencies.

### Removed
- Dropped support for Rails `5.0` and `5.1`. 

## [0.2.1] - 2021-01-13
### Fixed
- Scopes handling. The scope passed from client requests was ignored, and the
  resulting access token scope was always the default one. This has been fixed,
  and Doorkeeper's `enforce_configured_scopes` setting is also honored
  (refer to https://doorkeeper.gitbook.io/guides/ruby-on-rails/scopes).

## [0.2.0] - 2021-01-08
### Added
- Add "Example Application" section to the README.
- Install `rubocop-rails` development dependency.
- Add Rails version `6.1` to Travis CI testing matrix.
- Add Ruby version `3.0` to Travis CI testing matrix, running only together
  with Rails version `>= 6.0`.

### Changed
- [#2] Extract `DeviceGrant` implementation into new module `DeviceGrantMixin`.
- Upgrade development dependencies.
- Upgrade RuboCop as well, keep its config file up to date, and refactor the
  code solving new offenses.

## [0.1.1] - 2020-06-30
### Fixed
- Add missing required Ruby version Gem Specification attribute.
- Change RuboCop target Ruby version according to the Gem Specification (see above).

## [0.1.0] - 2020-06-30
### Added
- First release!
