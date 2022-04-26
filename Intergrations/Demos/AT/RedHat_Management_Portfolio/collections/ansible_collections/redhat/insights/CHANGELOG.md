# Insights Collection Changes

## [1.0.1]
### Added
  - Tagging support from 0.0.2 release

## [1.0.0]
### Added
 - Production Release

## [0.0.2]
### Added
  - `insights_tags` variable for the `insights_client` role to deploy tags to managed systems
  - `get_tags` option for inventory plugin to pull tags as variables
  - `filter_tags` option for inventory plugin to filter hosts server side by tag
  - added examples for filtering by tag and creating groups from tags

## [0.0.2]
### Added
 - get_patching option added to insights inventory plugin fetches patching data from Insights patching service.
 - vars_prefix option added to insights inventory plugin allows for customization of host var variable prefix.
 - added docs for modules and role
 - added role for Insights compliance

### Fixed
 - updated inventory endpoint url to include all staleness states.

### Removed
  - `ansible_host` variable no longer set by default from inventory plugin. Set `ansible_host` with compose.

### Removed
  - `ansible_host` variable no longer set by default from inventory plugin. Set `ansible_host` with compose.

## [0.0.1]
### Added
 - insights_client role for installing and registering a system to insights. Note: if migrating from previous version of role, name has changed from `insights-client` to `insights_client`.
 - insights inventory plugin for fetching dynamic inventory from Insights inventory service.
