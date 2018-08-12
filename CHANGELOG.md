# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]



## [v1.4.2] - 2018-08-12

- 🚏📥🙅🏻‍♀️ Disabled `signin` command on macOS 10.13+ #162
  - An error is immediately returned instead of crashing on newer macOS versions.
  - See #164 for updates on this issue.
- 🐛 Fixed `signout` command #162
- 🐛 Fixed `account` command #165
- ✨ Added price to `search` command when `--price` flag specified #62, #148
- 🎨 `search` output is now formatted in columns #148
- ➖ CocoaSeeds #155
- ➕🍫 CocoaPods (1.5.3) #155
- 🛠 Xcode 9.4 #153
- 🛠 Xcode 9.3 #141
- 👷🏻‍♀️⚠️ Re-enabled Danger #137

## [v1.4.1] Stop Littering - 2018-02-18

- 🐛 Prevent `default.profraw` from getting created #135

## [v1.4.0] It's Alive! 🧟‍♂️ - 2018-02-16

### ✨ Enhancements
- ℹ️ Info command #26, #55
- 🍀 Lucky command #88
- 🕵🏽‍♀️ Include version number in search output #131
- ☝🏻 Support app name(s) arugments for upgrade command #100

### 🔨 Xcode Project
- ⬆️ Swift 4 #114
- ✅ Added test target #127
- 📛 Add build badge to readme #121
- 💎 Configure bundler #118

### 🐙 GitHub
- ⚠️ Added Danger for PR feedback #124
- 📝🤝🎨 Added Contributing Guidelines, Code of Conduct and style guide #117, #126
- 📝 Added CHANGELOG #119
- 📝 Added note about installing through app store first #93

### 🏛 Dependencies #122
- ⬆️ Commandant (0.13.0)
- ⬆️ Result (3.2.4)
- ⬆️ cocoaseeds (0.8.3)
- ⬆️ xcpretty (0.2.8)

### 👷🏻‍♀️ CI Build
- 🍎 Now using [`xcode9.2`](https://docs.travis-ci.com/user/reference/osx#Xcode-9.2) image for `macosx10.13` SDK #120

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

[Unreleased]: https://github.com/mas-cli/mas/compare/v1.4.2...HEAD
[v1.4.2]: https://github.com/mas-cli/mas/compare/v1.4.1...v1.4.2
[v1.4.1]: https://github.com/mas-cli/mas/compare/v1.4.0...v1.4.1
[v1.4.0]: https://github.com/mas-cli/mas/compare/v1.3.1...v1.4.0
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
