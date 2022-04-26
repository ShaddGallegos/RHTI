# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.9] - 2020-10-28
### Fixed
- `configs/inet_http_server.conf.j2` used old style macros

## [2.0.8] - 2020-10-27
### Fixed
- Boolean evaluations in filters

## [2.0.7] - 2020-10-26
### Added
- Config filters
- Flatten configs array

## [2.0.6] - 2020-10-20
### Changed
- Config file names based on template name if not provided
- Exclusive mode applied on all files (not only `*.conf`)

## [2.0.5] - 2020-09-29
### Added
- Configs can be individually ignored

## [2.0.4] - 2020-08-26
### Fixed
- Fix `inet_http_server` config template (default config handling)

## [2.0.3] - 2020-08-03
### Changed
- Use unified exclusive template lookup
- Deprecate environment oriented templates
- Deprecate dict's array configs

## [2.0.2] - 2020-02-13
### Added
- Tags for each tasks, with the format `manala_rolename.taskname`

## [2.0.1] - 2019-11-29
- Update 'lookup' to use 'query'
- Minimum required version of ansible up to 2.5.0

## [2.0.0] - 2019-11-21
### Removed
- Debian wheezy support

### Added
- Handle configs raw content

## [1.0.7] - 2019-10-24
### Added
- Debian buster support

### Changed
- Debian Stretch now using debian-backports instead of Manala package

## [1.0.6] - 2019-09-25
### Changed
- Update configs templates based on version 3.3.5 (mainly comments)

## [1.0.5] - 2018-10-17
### Fixed
- Python 3 compatibility

## [1.0.4] - 2018-08-21
### Added
- Ensure configs directory is present
- Support configs state (present|absent)

## [1.0.3] - 2018-06-05
### Added
- Handle dependency packages to install

### Changed
- Replace deprecated uses of "include"
- Pass apt module packages list directly to the `name` option

## [1.0.2] - 2018-03-28
### Added
- Allow to pass 'environment' dictionary to supervisor configs

## [1.0.1] - 2017-12-06
### Added
- Debian stretch support

### Fixed
- Fix tests

## [1.0.0] - 2017-06-09
### Added
- Handle installation
- Handle config(s)
- Handle services
