# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Added test target #127
- Added the version number to search output

## [v1.3.1] Better Errors - 2016-09-25
- Descriptive error messages instead of exit codes
- Fixed nullability issue with `list` command
- Simpler upgrade checking

## [v1.3.0] Multiple app install - 2016-09-14
- Fix install of Free apps (#19)
- Install / Upgrade multiple apps at once
- Skip Install if the app is already installed

## [v1.2.2] Secure Password entry - 2016-09-14
- Support reading password from STDIN
- Fix building with Swift 2.3/Xcode 8

## [v1.2.1] - 2016-09-13
- Support reading password from STDIN
- Fix building with Swift 2.3/Xcode 8

## [v1.2.0] Search - 2016-04-16
- `search` command
- Fix `mas list` illegal instruction (#16)

## [v1.1.3] - 2016-02-21
- Fix Illegal Instruction: 4 error (#10)

## [v1.1.2] Upload dSYM correctly - 2016-02-21
- Move the dSYM to the xcarchive

## [v1.1.1] Upload dSYM - 2016-02-21
- Upload dSYM from Travis release

## [v1.1.0] Sign In - 2016-02-13
- Added `signin` command (#3)
- Added `signout` command

## [v1.0.2] Upgrade all - 2015-12-30
### Features
- Added `upgrade` command (#1)

### Fixes
- Updated to latest version of Commandant
- Broken `install` command after updating Commandant

## [v1.0.1] - 2015-12-30
- Bump version to 1.0.1

## [v1.0.0] - 2015-09-20
- Initial Release

[Unreleased]: https://github.com/mas-cli/mas/compare/v1.3.1...HEAD
[v1.3.1]: https://github.com/mas-cli/mas/compare/v1.3.0...v1.3.1
[v1.3.0]: https://github.com/mas-cli/mas/compare/v1.2.2...v1.3.0
[v1.2.2]: https://github.com/mas-cli/mas/compare/v1.2.1...v1.2.2
[v1.2.1]: https://github.com/mas-cli/mas/compare/v1.2.0...v1.2.1
[v1.2.0]: https://github.com/mas-cli/mas/compare/v1.1.2...v1.2.0
[v1.1.3]: https://github.com/mas-cli/mas/compare/v1.1.2...v1.1.3
[v1.1.2]: https://github.com/mas-cli/mas/compare/v1.1.1...v1.1.2
[v1.1.1]: https://github.com/mas-cli/mas/compare/v1.1.0...v1.1.1
[v1.1.0]: https://github.com/mas-cli/mas/compare/v1.0.2...v1.1.0
[v1.0.2]: https://github.com/mas-cli/mas/compare/v1.0.1...v1.0.2
[v1.0.1]: https://github.com/mas-cli/mas/compare/v1.0.0...v1.0.1
[v1.0.0]: https://github.com/mas-cli/mas/compare/7e0e18d8335cf5eee6a162ea7981ad02ca4294b2...v1.0.0
