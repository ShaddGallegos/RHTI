# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.0.10] - 2020-08-28
### Changed
- Explicit file permissions

## [1.0.9] - 2020-06-04
### Fixed
- Home directory mode

## [1.0.8] - 2020-03-31
### Added
- Automatic creation of home directory for virtual users.

## [1.0.7] - 2020-02-13
### Added
- Tags for each tasks, with the format `manala_rolename.taskname`

## [1.0.6] - 2019-11-29
### Changed
- Update 'lookup' to use 'query'
- Minimum required version of ansible up to 2.5.0

### Added
- Handle configs raw content

## [1.0.5] - 2019-10-24
### Added
- Debian buster support

## [1.0.4] - 2018-10-31
### Removed
- Remove Debian Wheezy support

### Added
- Enhanced proftpd configuration through yaml

## [1.0.3] - 2018-10-17
### Fixed
- Python 3 compatibility

## [1.0.2] - 2018-06-05
### Added
- Handle dependency packages to install

### Changed
- Replace deprecated uses of "include"
- Pass apt module packages list directly to the `name` option

## [1.0.1] - 2017-12-06
### Added
- Debian stretch support

## [1.0.0] - 2017-07-17
### Added
- Handle install
- Handle configs
- Handle users
- Handle services
