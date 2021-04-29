# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Upgrade `doorkeeper` dependency, matching versions `~> 5.5`.
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
