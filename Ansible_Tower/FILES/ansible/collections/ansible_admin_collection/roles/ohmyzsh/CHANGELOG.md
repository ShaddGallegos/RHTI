# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.10] - 2020-10-26
### Added
- Flatten themes array

## [2.0.9] - 2020-10-20
### Changed
- Custom theme file names based on template name if not provided
- Exclusive mode applied on all files (not only `*.zsh-theme`)

## [2.0.8] - 2020-10-13
### Changed
- Update users templates

## [2.0.7] - 2020-10-12
### Added
- Ensure destination directory exists
- Handle users state (present|ignore)
- Handle custom themes

## [2.0.6] - 2020-08-26
### Changed
- Explicit file permissions

## [2.0.5] - 2020-06-09
### Removed
- Thefuck plugin support

## [2.0.4] - 2020-06-05
### Changed
- Update templates

## [2.0.3] - 2020-05-27
### Changed
- Update templates

## [2.0.2] - 2020-02-13
### Added
- Tags for each tasks, with the format `manala_rolename.taskname`

## [2.0.1] - 2019-12-26
### Changed
- Update templates
- Update repo after migration

## [2.0.0] - 2019-11-21
### Removed
- Debian wheezy support

## [1.0.10] - 2019-10-24
### Added
- Debian buster support

## [1.0.9] - 2019-01-25
### Changed
- Update templates

## [1.0.8] - 2018-11-12
### Removed
- Thefuck plugin support for debian wheezy

## [1.0.7] - 2018-10-17
### Fixed
- Python 3 compatibility

## [1.0.6] - 2018-06-05
### Changed
- Replace deprecated jinja tests used as filters

### Changed
- Replace deprecated uses of "include"
- Pass apt module packages list directly to the `name` option

## [1.0.5] - 2018-01-31
### Added
- Yarn plugin in php users template

## [1.0.4] - 2017-12-06
### Added
- Debian stretch support

## [1.0.3] - 2017-10-24
### Fixed
- Default user template ssh key path (See: https://github.com/ohmyzsh/ohmyzsh/pull/5603)

## [1.0.2] - 2017-10-20
### Fixed
- Fixed ohmyzsh prompt issue causing troubles with terminal buffer

## [1.0.1] - 2017-09-25
### Changed
- Skip linting on manual git usage
- Explicit git checkout version

## [1.0.0] - 2017-07-17
### Added
- Handle install
- Handle themes
- Handle users
