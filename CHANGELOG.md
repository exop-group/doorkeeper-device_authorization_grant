# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Add "Example Application" section to the README.
- Install `rubocop-rails` development dependency.

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
