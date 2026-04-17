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

## Usage

### App IDs

Each App Store app has a unique integer app identifier (ADAM ID) & a unique text
app identifier (bundle ID).

mas commands accept both types of app IDs as arguments.

App IDs that contain only digits are automatically processed as ADAM IDs; other
app IDs are processed as bundle IDs.

The `--bundle` flag forces all app IDs (including all-digit ones) in a command
line to be processed as bundle IDs (all-digit bundle IDs are theoretically
possible, but likely don't exist).

`mas search <search-term>…` & `mas list` can be used to find app ADAM IDs.

Alternatively, to find an app's ADAM ID:

1. Open an app's App Store page
2. Open the page's Share Sheet via the Share Button (an up arrow superimposed
   over a square)
3. Choose `Copy`
4. Extract the ADAM ID from the URL in the copied text
   - e.g., extract ADAM ID `497799835` from the URL for Xcode
     (<https://apps.apple.com/us/app/xcode/id497799835?mt=12>)

### `mas search`

`mas search <search-term>…` searches by name for apps available from the App
Store.

The `--price` flag includes each app's price in the output.

```console
$ mas search --price Xcode
 497799835  Xcode       (26.4)   Free
1602932893  Clouded CI  (1.0.3)  Free
…
```

### `mas lookup`

`mas lookup <app-id>…` outputs more detailed information about apps available
from the App Store.

`lookup` was formerly `info`; the `info` alias exists for backwards
compatibility.

```console
$ mas lookup 497799835
Xcode 26.1.1 [Free]
By: Apple Inc.
Released: 2025-11-11
Minimum OS: 15.6
Size: 2,913.8 MB
From: https://apps.apple.com/us/app/xcode/id497799835?mt=12&uo=4
```

### `mas list`

`mas list` outputs apps installed from the App Store.

```console
$ mas list
640199958  Developer   (10.8.3)
899247664  TestFlight  (4.1.0)
497799835  Xcode       (26.4)
```

### `mas outdated`

`mas outdated` outputs apps installed from the App Store that have pending
updates.

```console
$ mas outdated
640199958  Developer  (10.8.2 -> 10.8.3)
497799835  Xcode      (26.3   -> 26.4)
```

Run [`mas update`](#mas-update) to install pending updates.

### `mas get`

`mas get <app-id>…` gets & installs free apps from the App Store.

mas cannot purchase paid apps; purchase them directly in the App Store.

The `--force` flag re-installs apps even if they are already installed; without
it, already installed apps are not modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#root-privileges).

While getting an app, depending on your Apple Account settings, your Apple
Account might need to be authenticated in the App Store, even if it is already
signed in to the App Store.

If `System Settings` > `Touch ID & Password` > `Use Touch ID for purchases in
iTunes Store, App Store and Apple Books` is enabled, then you must authenticate
(either via Touch ID or via your Apple Account password) for each previously
ungotten app that you get.

If that setting is disabled, then if `System Settings` > `Apple Account` >
`Media & Purchases` > `Free Downloads` is set to `Always Require`, then you must
authenticate via your Apple Account password for each previously ungotten app
that you get.

`get` was formerly `purchase`; the `purchase` alias exists for backwards
compatibility.

```console
$ mas get 497799835
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Getting Xcode (26.4)
==> Got Xcode (26.4) in /Applications/Xcode.app
```

### `mas install`

`mas install <app-id>…` installs apps from the App Store.

`mas install` installs only apps that have already been gotten or purchased by
the Apple Account signed in to the App Store. If a free app hasn't already been
gotten, use [`mas get`](#mas-get); if a paid app hasn't been purchased, purchase
it in the App Store.

The `--force` flag re-installs apps even if they are already installed; without
it, already installed apps are not modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#root-privileges).

```console
$ mas install 497799835
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Installing Xcode (26.4)
==> Installed Xcode (26.4) in /Applications/Xcode.app
```

### `mas lucky`

`mas lucky <search-term>…` installs the first result that would be returned by
`mas search <search-term>…`.

Like `mas install`, `mas lucky` can install only apps that have previously been
gotten or purchased.

Requires an Apple Account signed in to the App Store &
[root privileges](#root-privileges).

```console
$ mas lucky Xcode
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Installing Xcode (26.4)
==> Installed Xcode (26.4) in /Applications/Xcode.app
```

### `mas update`

`mas update` updates outdated apps installed from the App Store.

Without any app ID arguments, it updates all outdated apps.

App ID arguments restrict the apps that might be updated.

The `--force` flag updates apps even if they aren't outdated; without it, only
outdaetd apps are modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#root-privileges).

`update` was formerly `upgrade`; the `upgrade` alias exists for backwards
compatibility.

```console
$ mas update
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Updating Xcode (26.4)
==> Updated Xcode (26.4) in /Applications/Xcode.app
==> Downloading Apple Developer (10.8.3)
==> Downloaded Apple Developer (10.8.3)
==> Updating Apple Developer (10.8.3)
==> Updated Apple Developer (10.8.3) in /Applications/Developer.app
```

Updates can be performed selectively by providing app IDs to `mas update`.

```console
$ mas update 497799835
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Updating Xcode (26.4)
==> Updated Xcode (26.4) in /Applications/Xcode.app
```

### `mas signout`

`mas signout` signs out from the Apple Account signed in to the App Store.

### Spotlight

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

### Root Privileges

`get`, `install`, `lucky`, `update` & `uninstall` require root privileges.

If run without root privileges, mas requests them as necessary.

mas uses existing valid sudo credentials, falling back to prompting for the
macOS user password, which is piped directly to a sudo process; the password is
never visible to, nor stored by, mas.

Any sudo credentials used or established by mas remain valid after mas finishes,
pursuant to the user-configured sudo timeout.

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
| [Cannot purchase paid apps](https://github.com/mas-cli/mas/issues/558)     | Purchase paid apps directly in App Store; submit PR                                                                                                              |
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

Licensed under the [MIT license](LICENSE).

Originally created by Andrew Naylor
([@argon on GitHub](https://github.com/argon) /
[@argon on X](https://x.com/argon)).
