# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [3.0.3] - 2020-08-26
### Changed
- Explicit file permissions

## [3.0.2] - 2020-07-09
### Changed
- Stop printing last log on dev/test server config template

## [3.0.1] - 2020-06-23
### Changed
- More permissive client test config template

## [3.0.0] - 2020-06-23
### Added
- Both `manala_ssh_server` and `manala_ssh_client` variables to allow both
  `server` and `client` ssh components handling

### Changed
- Rename variables according to `server` and `client` ssh components introduction

## [2.0.2] - 2020-02-13
### Added
- Tags for each tasks, with the format `manala_rolename.taskname`

## [2.0.1] - 2019-11-29
### Changed
- Update 'lookup' to use 'query'
- Minimum required version of ansible up to 2.5.0

## [2.0.0] - 2019-11-21
### Removed
- Debian wheezy support

## [1.0.6] - 2019-10-24
### Added
- Debian buster support

## [1.0.5] - 2018-10-17
### Fixed
- Python 3 compatibility

## [1.0.4] - 2018-07-10
### Fixed
- RekeyLimit parameter as default on debian jessie/stretch client config template

## [1.0.3] - 2018-06-05
### Added
- Handle dependency packages to install

### Changed
- Replace deprecated uses of "include"
- Pass apt module packages list directly to the `name` option

## [1.0.2] - 2017-12-06
### Added
- Debian stretch support

## [1.0.1] - 2017-10-07
### Added
- Config sshd tests

### Changed
- Don't redefine already default options in default sshd config templates

### Removed
- Unused testing files

## [1.0.0] - 2017-07-17
### Added
- Handle install
- Handle config
- Handle known hosts
- Handle services
