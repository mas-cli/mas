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

<details>
<summary>

## Installation

</summary>

🍺 The [Homebrew](https://brew.sh) Core
[mas formula](https://formulae.brew.sh/formula/mas) is the preferred way to
install on macOS 14+:

```shell
brew install mas
```

🚰 The
[mas-cli Homebrew tap mas formula](https://github.com/mas-cli/homebrew-tap) is
an alternative way to install on macOS 13+:

```shell
brew install mas-cli/tap/mas
```

🔌 The [MacPorts](https://www.macports.org/install.php)
[mas port](https://ports.macports.org/port/mas/) is an alternative way to
install on macOS 13+:

```shell
sudo port install mas
```

🐙 [GitHub Releases](https://github.com/mas-cli/mas/releases) provides `.pkg`
installers & source archives for every release.

</details>
<details>
<summary>

## Usage

</summary>
<details>
<summary>

### 🆔 App IDs

</summary>

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

</details>
<details>
<summary>

### 🔍 `mas search`

</summary>

`mas search <search-term>…` searches by name for apps available from the App
Store.

The `--price` flag includes each app's price in the output.

```console
$ mas search --price Xcode
 497799835  Xcode       (26.4)   Free
1602932893  Clouded CI  (1.0.3)  Free
…
```

</details>
<details>
<summary>

### 👀 `mas lookup`

</summary>

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

</details>
<details>
<summary>

### 📜 `mas list`

</summary>

`mas list` outputs apps installed from the App Store.

```console
$ mas list
640199958  Developer   (10.8.3)
899247664  TestFlight  (4.1.0)
497799835  Xcode       (26.4)
```

</details>
<details>
<summary>

### ⌛ `mas outdated`

</summary>

`mas outdated` outputs apps installed from the App Store that have pending
updates.

```console
$ mas outdated
640199958  Developer  (10.8.2 -> 10.8.3)
497799835  Xcode      (26.3   -> 26.4)
```

Run [`mas update`](#-mas-update) to install pending updates.

</details>
<details>
<summary>

### ✨ `mas get`

</summary>

`mas get <app-id>…` gets & installs free apps from the App Store.

mas cannot purchase paid apps; purchase them directly in the App Store.

The `--force` flag re-installs apps even if they are already installed; without
it, already installed apps are not modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#-root-privileges).

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

</details>
<details>
<summary>

### ⬇️ `mas install`

</summary>

`mas install <app-id>…` installs apps from the App Store.

`mas install` installs only apps that have already been gotten or purchased by
the Apple Account signed in to the App Store. If a free app hasn't already been
gotten, use [`mas get`](#-mas-get); if a paid app hasn't been purchased,
purchase it in the App Store.

The `--force` flag re-installs apps even if they are already installed; without
it, already installed apps are not modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#-root-privileges).

```console
$ mas install 497799835
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Installing Xcode (26.4)
==> Installed Xcode (26.4) in /Applications/Xcode.app
```

</details>
<details>
<summary>

### 🍀 `mas lucky`

</summary>

`mas lucky <search-term>…` installs the first result that would be returned by
`mas search <search-term>…`.

Like `mas install`, `mas lucky` can install only apps that have previously been
gotten or purchased.

Requires an Apple Account signed in to the App Store &
[root privileges](#-root-privileges).

```console
$ mas lucky Xcode
==> Downloading Xcode (26.4)
==> Downloaded Xcode (26.4)
==> Installing Xcode (26.4)
==> Installed Xcode (26.4) in /Applications/Xcode.app
```

</details>
<details>
<summary>

### 🆙 `mas update`

</summary>

`mas update` updates outdated apps installed from the App Store.

Without any app ID arguments, it updates all outdated apps.

App ID arguments restrict the apps that might be updated.

The `--force` flag updates apps even if they aren't outdated; without it, only
outdaetd apps are modified.

Requires an Apple Account signed in to the App Store &
[root privileges](#-root-privileges).

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

</details>
<details>
<summary>

### 🚪 `mas signout`

</summary>

`mas signout` signs out from the Apple Account signed in to the App Store.

</details>
<details>
<summary>

### 🔑 Root privileges

</summary>

Root privileges are now necessary to install or update apps from the App Store,
because Apple secured `installd` on macOS 26.1+, 15.7.2+ & 14.8.2+ to fix
[CVE-2025-43411](https://nvd.nist.gov/vuln/detail/CVE-2025-43411). To simplify
the code, mas 4.0.0+ requires root privileges to install or update apps for all
versions of macOS, even older versions for which `installd` hasn't been secured.
Most users are already, or soon will be, using affected macOS versions.

Root privileges were always necessary to uninstall apps from the App Store,
because such apps are owned by the `root` user on macOS.

If mas 4.0.0+ needs root privileges yet was run without them, mas requests them
by spawning an external process that uses sudo to run mas. If existing sudo
credentials are within the sudo timeout, the spawned sudo automatically uses
them. If no such sudo credentials exist, the spawned sudo prompts for the macOS
user password; the provided password is piped directly from the sudo process, so
the password is never visible to mas, nor is it stored in any way.

Any sudo credentials used or established by mas remain valid after mas finishes,
pursuant to the user-configured sudo timeout.

</details>
</details>
<details>
<summary>

## Integrations

</summary>

🍻 [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile): If mas is
installed:

- `brew bundle dump` includes installed App Store apps in the generated
  `Brewfile`
- Homebrew Bundle commands process App Store apps included in a `Brewfile`

⚙️ [Topgrade](https://github.com/topgrade-rs/topgrade): If mas is installed,
Topgrade updates installed App Store apps.

</details>
<details>
<summary>

## Known issues

</summary>
<details>
<summary>

### &nbsp;&nbsp;&nbsp; System software

</summary>

mas manages apps only from the App Store.

Use [`softwareupdate`](https://www.unix.com/man-page/osx/8/softwareupdate) to
manage system software (e.g., macOS, Xcode Command Line Tools, Safari, etc.).

</details>
<details>
<summary>

### 💥 Broken Apple private frameworks

</summary>

mas uses multiple undocumented Apple private frameworks to implement much of its
functionality.

Over time, Apple has silently changed these frameworks, breaking some
functionality, including:

- [`account` not supported on macOS 12+](
    https://github.com/mas-cli/mas/issues/417
  )
- [`signin` not supported on macOS 10.13+](
    https://github.com/mas-cli/mas/issues/164
  )

</details>
<details>
<summary>

### ⏳ Eventual consistency

</summary>

The App Store operates on eventual consistency.

[The app versions seen by various parts of mas or the App Store might be
inconsistent for days](https://github.com/mas-cli/mas/issues/387).

</details>
<details>
<summary>

### 📱 iOS & iPadOS apps

</summary>

Apple Silicon Macs can install iOS & iPadOS apps from the App Store.

[mas does not yet support iOS or iPadOS apps](
  https://github.com/mas-cli/mas/issues/321
).

</details>
<details>
<summary>

### 🤷 Undetected installed apps

</summary>

mas 2.0.0+ sources data for installed App Store apps from macOS's Spotlight
Metadata Server (aka MDS).

Check if an App Store app is properly indexed in Spotlight via:

```console
## General format:
$ mdls -rn kMDItemAppStoreAdamID <path-to-app>
## Outputs the ADAM ID if the app is indexed
## Outputs nothing if the app is not indexed

## Example:
$ mdls -rn kMDItemAppStoreAdamID /Applications/WhatsApp.app
310633997
```

If an app has been indexed in Spotlight, find the path to the app for an ADAM ID
via:

```shell
mdfind 'kMDItemAppStoreAdamID = <adam-id>'
```

Reindex improperly indexed App Store apps via:

```shell
# Individual apps (if the incorrectly omitted apps are known):
mdimport /Applications/Example.app

# All apps (<LargeAppVolume> is the volume optionally selected for large apps):
mdimport /Applications /Volumes/<LargeAppVolume>/Applications

# All file system volumes (if neither aforementioned command solved the issue):
sudo mdutil -Eai on
```

</details>
<details>
<summary>

### 🚫 Redownload not available

</summary>

If the following error is reported, the app was probably gotten or purchased by
a different Apple Account.

> This redownload is not available for this Apple Account either because it was
> bought by a different user or the item was refunded or canceled.

Either:

1. Uninstall the app if it's already installed.
2. Get or purchase the app.

Or:

1. Sign out this Apple Account from the App Store.
2. Sign in the other Apple Account to the App Store.
3. Install or update the app.

</details>
<details>
<summary>

### ❓ Other issues

</summary>

If mas doesn't work as expected (e.g., apps can't be installed or updated), run
`mas reset`, then try again.

If the issue persists, please [file a bug](
  https://github.com/mas-cli/mas/issues/new?template=01-bug-report.yaml
).

Feedback is much appreciated!

</details>
</details>
<details>
<summary>

## Development

</summary>

🏗 mas can be built in Xcode 26+ or via:

```shell
Scripts/build
```

🧪 [Swift Testing](https://developer.apple.com/xcode/swift-testing) tests are
run via:

```shell
Scripts/test
```

📄 Licensed under the [MIT license](LICENSE).

✍️ Originally created by Andrew Naylor
([@argon on GitHub](https://github.com/argon) /
[@argon on X](https://x.com/argon)).

</details>
