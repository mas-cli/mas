<h1 align="center">

![mas](mas.png)

</h1>

<!--editorconfig-checker-disable-->
[![current release version](https://img.shields.io/github/v/release/mas-cli/mas.svg?style=for-the-badge)](https://github.com/mas-cli/mas/releases)
[![supported OS: macOS 13+](https://img.shields.io/badge/Supported_OS-macOS_13%2B-teal?style=for-the-badge)](Package.swift)
[![license: MIT](https://img.shields.io/badge/license-MIT-750014.svg?style=for-the-badge)](LICENSE)
[![language: Swift 6.2](https://img.shields.io/badge/language-Swift_6.2-F05138.svg?style=for-the-badge)](https://www.swift.org)
[![build, test & lint status](https://img.shields.io/github/actions/workflow/status/mas-cli/mas/build-test.yaml?label=build,%20test%20%26%20lint&style=for-the-badge)](
  https://github.com/mas-cli/mas/actions/workflows/build-test.yaml?query=branch%3Amain
)
[![dependencies status](https://img.shields.io/librariesio/github/mas-cli/mas?style=for-the-badge)](Package.swift)
<!--editorconfig-checker-enable-->

mas is a command-line interface for the Mac App Store designed for scripting &
automation.

## Installation

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
| Provider                                                                   | Method                         | mas    | macOS             |
|:---------------------------------------------------------------------------|:-------------------------------|:-------|:------------------|
| [Homebrew](https://brew.sh) [Core](https://formulae.brew.sh/formula/mas)   | `brew install mas`             | Latest | 14+ (recommended) |
| [Homebrew](https://brew.sh) [Tap](https://github.com/mas-cli/homebrew-tap) | `brew install mas-cli/tap/mas` | Latest | 13+               |
| [MacPorts](https://www.macports.org/install.php)                           | `sudo port install mas`        | Latest | 13+               |
| [GitHub Releases](https://github.com/mas-cli/mas/releases)                 | Installers & source archives   | Any    | Release-dependent |
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## App IDs

App Store apps each have 2 unique IDs:

| Type      | Format  | Example (for Xcode) |
|:----------|:--------|:--------------------|
| ADAM ID   | Integer | 497799835           |
| Bundle ID | String  | com.apple.dt.Xcode  |

mas commands accept both types of app IDs as arguments.

By default, all-digit app IDs are considered ADAM IDs; other app IDs are
considered bundle IDs.

`--bundle` forces all-digit app IDs to also be considered bundle IDs.

ADAM IDs can be found via:

1. `mas search <term>…`
2. `mas list`
3. The App Store:
   1. Open an app's App Store page
   2. Open the page's Share Sheet
   3. Choose `Copy`
   4. Extract the ADAM ID from the URL in the copied text
      - e.g., `497799835` from
        <https://apps.apple.com/us/app/xcode/id497799835?mt=12>

## Commands

Detailed documentation is available via `man mas` & `mas --help`.

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
| Command                    | Functionality                                 | Requires                                                                                                              |
|:---------------------------|:----------------------------------------------|:----------------------------------------------------------------------------------------------------------------------|
| `search <term>…`           | Search for App Store apps by name             |                                                                                                                       |
| `lookup <id>…`             | Output App Store app details                  |                                                                                                                       |
| `info <id>…`               | `lookup` alias                                |                                                                                                                       |
| `list [<id>…]`             | Output installed apps                         | [spotlight](#spotlight)                                                                                               |
| `outdated [<id>…]`         | Output outdated apps                          | [spotlight](#spotlight), [account](#apple-account-signed-in-to-app-store) for `--accurate`                            |
| `get <id>…`                | [Get free apps](#paid-apps), install any apps | [spotlight](#spotlight), [root](#root-privileges), [account for `get`](#apple-account-signed-in-to-app-store-for-get) |
| `purchase <id>…`           | `get` alias                                   | [spotlight](#spotlight), [root](#root-privileges), [account for `get`](#apple-account-signed-in-to-app-store-for-get) |
| `install <id>…`            | Install already gotten or purchased apps      | [spotlight](#spotlight), [root](#root-privileges), [account](#apple-account-signed-in-to-app-store)                   |
| `lucky <term>…`            | Install first app from `search <term>…`       | [spotlight](#spotlight), [root](#root-privileges), [account](#apple-account-signed-in-to-app-store)                   |
| `update [<id>…]`           | Update outdated apps                          | [spotlight](#spotlight), [root](#root-privileges), [account](#apple-account-signed-in-to-app-store)                   |
| `upgrade [<id>…]`          | `update` alias                                | [spotlight](#spotlight), [root](#root-privileges), [account](#apple-account-signed-in-to-app-store)                   |
| `uninstall (<id>…\|--all)` | Uninstall apps                                | [spotlight](#spotlight), [root](#root-privileges)                                                                     |
| `signout`                  | Sign out Apple Account from App Store         |                                                                                                                       |
| `open [<id>]`              | Open app App Store page                       |                                                                                                                       |
| `home <id>…`               | Open app web pages                            |                                                                                                                       |
| `seller <id>…`             | Open seller app web pages                     |                                                                                                                       |
| `vendor <id>…`             | `seller` alias                                |                                                                                                                       |
| `reset`                    | Reset App Store processes                     |                                                                                                                       |
| `config`                   | Output config                                 |                                                                                                                       |
| `version`                  | Output version                                |                                                                                                                       |
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## Spotlight

`list`, `outdated`, `get`, `install`, `lucky`, `update` & `uninstall` obtain
data for installed apps from the Spotlight Metadata Service (MDS).

Spotlight indexing thus must be enabled & valid for folders containing App Store
apps.

Check if an app is properly indexed in Spotlight via:

```console
## General format:
$ mdls -rn kMDItemAppStoreAdamID <path-to-app>
## Outputs the ADAM ID if the app is indexed
## Outputs nothing if the app is not indexed

## Example:
$ mdls -rn kMDItemAppStoreAdamID /Applications/Xcode.app
497799835
```

If an app is indexed in Spotlight, find the path to the app from its ADAM ID
via:

```shell
mdfind 'kMDItemAppStoreAdamID = <adam-id>'
```

If any App Store apps are not properly indexed, index via:

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
```shell
# Individual app (if the omitted apps are known). e.g., for Xcode:
mdimport /Applications/Xcode.app

# All apps:
vol="$(/usr/libexec/PlistBuddy -c "Print :PreferredVolume:name" ~/Library/Preferences/com.apple.appstored.plist 2>/dev/null)"
mdimport /Applications ${vol:+"/Volumes/${vol}/Applications"}

# All volumes:
sudo mdutil -Eai on
```
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## Root Privileges

`get`, `install`, `lucky`, `update` & `uninstall` require root privileges.

If run without root privileges, mas requests them as necessary.

mas uses existing valid sudo credentials, falling back to prompting for the
macOS user password, which is piped directly to a sudo process; the password is
never visible to, nor stored by, mas.

Any sudo credentials used or established by mas remain valid after mas finishes,
pursuant to the user-configured sudo timeout.

## Apple Account Signed in to App Store

`get`, `install`, `lucky`, `update` & `outdated --accurate` require an Apple
Account signed in to the App Store.

## Apple Account Signed in to App Store for `get`

`get` requires an Apple Account signed in to the App Store.

Depending on the Apple Account settings, the Apple Account might need to be
authenticated in the App Store for each gotten app, even if the Apple Account is
already signed in to the App Store.

If `System Settings` > `Touch ID & Password` > `Use Touch ID for purchases in
iTunes Store, App Store and Apple Books` is enabled, then you must authenticate
(either via Touch ID or via the Apple Account password) for each previously
ungotten app that is being gotten.

If that setting is disabled, then if `System Settings` > `Apple Account` >
`Media & Purchases` > `Free Downloads` is set to `Always Require`, then you must
authenticate via the Apple Account password for each previously ungotten app
that is being gotten.

## Integrations

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
| Tool                                                             | Functionality                                                               |
|:-----------------------------------------------------------------|:----------------------------------------------------------------------------|
| [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile) | Include installed apps in `Brewfile`; get, install & update `Brewfile` apps |
| [Topgrade](https://github.com/topgrade-rs/topgrade)              | Update apps                                                                 |
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## Known Issues

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
| Issue                                                                      | Solution                                                                                                                                                         |
|:---------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Manage system software (macOS, Safari…)                                    | Use [`softwareupdate`](https://www.unix.com/man-page/osx/8/softwareupdate)                                                                                       |
| [App info inconsistencies](https://github.com/mas-cli/mas/issues/387)      | Wait hours – days (App Store uses eventual consistency)                                                                                                          |
| [Cannot purchase paid apps](https://github.com/mas-cli/mas/issues/558)     | <a id="paid-apps"></a>Purchase paid apps directly in App Store; submit PR                                                                                        |
| [iOS & iPadOS apps unsupported](https://github.com/mas-cli/mas/issues/321) | Submit PR                                                                                                                                                        |
| [Hangs](https://github.com/mas-cli/mas/issues/1222)                        | [Index apps in Spotlight](#spotlight); [open bug report](https://github.com/mas-cli/mas/issues/new?template=01-bug-report.yaml) if hangs persist                 |
| Undetected installed apps                                                  | [Index apps in Spotlight](#spotlight)                                                                                                                            |
| `This redownload is not available for this Apple Account…` error           | Sign in correct Apple Account to App Store, or&nbsp;uninstall&nbsp;app&nbsp;&amp;&nbsp;get&nbsp;it&nbsp;with&nbsp;current&nbsp;Apple&nbsp;Account                |
| Other bugs                                                                 | [Subscribe to existing](https://github.com/mas-cli/mas/issues), or [open new](https://github.com/mas-cli/mas/issues/new?template=01-bug-report.yaml), bug report |
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## Development

<!--markdownlint-disable line-length-->
<!--editorconfig-checker-disable-->
| Action                                                                  | Command                      |
|:------------------------------------------------------------------------|:-----------------------------|
| Build                                                                   | `Scripts/build` or Xcode 26+ |
| Test ([Swift Testing](https://developer.apple.com/xcode/swift-testing)) | `Scripts/test`               |
<!--editorconfig-checker-enable-->
<!--markdownlint-enable line-length-->

## License

Licensed under the [MIT license](LICENSE).

Originally created by Andrew Naylor
([@argon on GitHub](https://github.com/argon) |
[@argon on X](https://x.com/argon)).
