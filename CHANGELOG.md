# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2023-04-11
### Fixed

- Fixed `DoubleRenderError` when inputting an invalid user code (#12).

## [1.0.2] - 2023-02-02
### Fixed
- Add compatibility with Doorkeeper 5.6.5 (#10).

### Added
- Install and enable new development dependency:
  [rubocop-performance](https://docs.rubocop.org/rubocop-performance/).

### Changed
- Update development dependencies.
- Update RuboCop configuration, including new preferences, and refactor the
  code to solve the new offenses.
- Opt-in for rubygems [MFA requirement](https://guides.rubygems.org/mfa-requirement-opt-in/).
- Replace Travis CI with a GitHub Actions CI Workflow.
- Test against additional Ruby and Rails versions.

## [1.0.1] - 2021-08-03
### Fixed
- Added compatibility with Doorkeeper's `hash_token_secrets` config option.

## [1.0.0] - 2021-05-12
### Added
- Register this Doorkeeper extension as `device_code` custom OAuth Grant Flow.

### Changed
- Upgrade `doorkeeper` dependency, matching versions `~> 5.5`.
- Use the standard IANA URN value `urn:ietf:params:oauth:grant-type:device_code`
  as grant type for device access token requests. It replaces the previous
  value `device_code`, which was deliberately nonstandard to make it work with
  Doorkeeper versions prior to `5.5`.

  This change requires you to update the `grant_type` parameter of the device
  access token requests from your clients, setting it to the aforementioned
  standard IANA URN value.
  More details about this request are available under the section
  `Device Access Token Request / polling` from the README
  ([link](https://github.com/exop-group/doorkeeper-device_authorization_grant#device-access-token-request--polling)).

  Depending on your installed version of Doorkeeper (in the range `~> 5.5`),
  the old `device_code` grant type value might still work out of the box,
  thanks to a fallback strategy provided by Doorkeeper gem itself.
  At the time of writing, using Doorkeeper `5.5.0` and `5.5.1`, the old grant
  type still works, but a warning message is printed at each request,
  announcing that this fallback strategy will be removed in newer
  versions of Doorkeeper.

  If you want to adequately support the old `device_code` grant type from
  your backend, you can simply register an additional Doorkeeper Grant Flow
  and enable it in Doorkeeper configuration. For the Grant Flow registration
  you can use the `Doorkeeper::Request::DeviceCode` strategy class as provided
  by this gem.

  For example, you can add the following code to an appropriate place, such
  as an initializer file:
  ```ruby
  Doorkeeper::GrantFlow.register(
    :legacy_device_code,
    grant_type_matches: 'device_code',
    grant_type_strategy: Doorkeeper::Request::DeviceCode
  )
  ```
  Then, you can enable this grant flow in Doorkeeper configuration, either
  in addition to or in place of the default grant flow, according to your needs:
  ```ruby
  Doorkeeper.configure do
    # ...

    grant_flows [
      'legacy_device_code',
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
