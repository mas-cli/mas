<h1 align="center">

![mas](mas.png)

</h1>

mas is a command-line interface for the Mac App Store that is designed for scripting & automation.

[![current release version](https://img.shields.io/github/v/release/mas-cli/mas.svg?style=for-the-badge)](https://github.com/mas-cli/mas/releases)
[![supported OS: macOS 10.15+](https://img.shields.io/badge/Supported_OS-macOS_10.15%2B-teal?style=for-the-badge)](Package.swift)
[![license: MIT](https://img.shields.io/badge/license-MIT-750014.svg?style=for-the-badge)](LICENSE)
[![language: Swift 6.0](https://img.shields.io/badge/language-Swift_6.0-F05138.svg?style=for-the-badge)](https://www.swift.org)
[![build, test & lint status](https://img.shields.io/github/actions/workflow/status/mas-cli/mas/build-test.yaml?label=build,%20test%20%26%20lint&style=for-the-badge)](
  https://github.com/mas-cli/mas/actions/workflows/build-test.yaml?query=branch%3Amain
)
[![dependencies status](https://img.shields.io/librariesio/github/mas-cli/mas?style=for-the-badge)](Package.swift)

<details>
<summary>

## 📲 Installation

</summary>
<details>
<summary>

### 🔮 macOS 10.15 (Catalina) or newer

</summary>
<details>
<summary>

#### 🍺 Homebrew Core formula

</summary>

[Homebrew](https://brew.sh) is the preferred way to install:

```shell
brew install mas
```

</details>
<details>
<summary>

#### 🔌 MacPorts

</summary>

[MacPorts](https://www.macports.org/install.php) is an alternative way to install:

```shell
sudo port install mas
```

</details>
</details>
<details>
<summary>

### 🧮 macOS 10.11 (El Capitan) - 10.14 (Mojave)

</summary>
<details>
<summary>

#### 🍻 Custom Homebrew tap

</summary>

The [mas custom Homebrew tap](https://github.com/mas-cli/homebrew-tap) provides pre-built bottles for all macOS versions
since 10.11 (El Capitan). The newest versions of mas, however, are only available for macOS 10.15+ (Catalina or newer).

To install mas from the custom tap:

```shell
brew install mas-cli/tap/mas
```

</details>
<details>
<summary>

#### 🐙 GitHub Releases

</summary>

Alternatively, binaries & sources are available from [GitHub Releases](https://github.com/mas-cli/mas/releases).

</details>
<details>
<summary>

#### 🕊 Swift 5 runtime support

</summary>

mas requires Swift 5 runtime support. macOS 10.14.4 (Mojave) & newer include it, but earlier releases do not. Without
it, running mas might report errors similar to:

> dyld: Symbol not found: _$s11SubSequenceSlTl

To get Swift 5 support on macOS versions older than 10.14.4 (Mojave), you can:

- Update to macOS 10.14.4 (Mojave) or newer.
- Install the [Swift 5 Runtime Support for Command Line Tools](https://support.apple.com/en-us/106446).
- Install Xcode 10.2 or newer to `/Applications/Xcode.app`.

</details>
</details>
</details>
<details>
<summary>

## 🤳 Usage

</summary>
<details>
<summary>

### 🪪 App IDs

</summary>

Each application in the Mac App Store has a unique integer app identifier (ADAM ID) & a unique text app identifier
(bundle ID). mas commands accept either form of app ID as arguments.

`mas search` & `mas list` can be used to find the ADAM IDs of apps.

Alternatively, to find an app's ADAM ID:

1. Find the app in the Mac App Store
2. Select `Share` > `Copy Link`
3. Extract the ADAM ID from the URL.
   - e.g., extract ADAM ID `497799835` from the URL for Xcode (<https://apps.apple.com/us/app/xcode/id497799835?mt=12>)

</details>
<details>
<summary>

### 🛍 Info from the Mac App Store

</summary>

None of the commands in this section require you to be logged into an Apple Account, neither for your macOS user nor in
the Mac App Store.

<details>
<summary>

#### `mas search`

</summary>

`mas search <search-term>` searches by name for applications available from the Mac App Store. Providing the `--price`
flag includes each app's price in the output.

```console
$ mas search Xcode
497799835 Xcode
688199928 Docs for Xcode
…
```

</details>
<details>
<summary>

#### `mas lookup`

</summary>

`mas lookup <app-id>` outputs more detailed information about an application available from the Mac App Store.

```console
$ mas lookup 497799835
Xcode 16.0 [Free]
By: Apple Inc.
Released: 2024-09-16
Minimum OS: 14.5
Size: 2.98 GB
From: https://apps.apple.com/us/app/xcode/id497799835?mt=12&uo=4
```

</details>
</details>
<details>
<summary>

### 📚 Info from your local app library

</summary>

All the commands in this section require you to be logged into an Apple Account for your macOS user.

<details>
<summary>

#### `mas list`

</summary>

`mas list` outputs all the applications on your Mac that were installed from the Mac App Store.

```console
$ mas list
497799835 Xcode       (15.4)
640199958 Developer   (10.6.5)
899247664 TestFlight  (3.5.2)
```

</details>
<details>
<summary>

#### `mas outdated`

</summary>

`mas outdated` outputs all applications installed from the Mac App Store on your Mac that have pending updates.

```console
$ mas outdated
497799835 Xcode (15.4 -> 16.0)
640199958 Developer (10.6.5 -> 10.6.6)
```

Run [`mas update`](#mas-update) to install pending updates.

</details>
</details>
<details>
<summary>

### ⬇️ Installing apps

</summary>

All the commands in this section require you to be logged into an Apple Account in the Mac App Store.

> Depending on your Apple Account settings, you might need to re-authenticate yourself in the Mac App Store to perform a
> get, install, lucky, or update, even if you are already signed in to an Apple Account in the Mac App Store.

<details>
<summary>

#### `mas get`

</summary>

`mas get <app-id>…` installs free applications that you haven't yet gotten/"purchased" from the Mac App Store.

> The `purchase` alias is currently a misnomer, because it currently can only "purchase" free apps. To purchase apps
> that cost money, please purchase them directly in the Mac App Store.

```console
$ mas get 497799835
==> Downloading Xcode
==> Installed Xcode
```

</details>
<details>
<summary>

#### `mas install`

</summary>

`mas install <app-id>…` installs apps that you have already gotten or purchased from the Mac App Store. Providing the
`--force` flag re-installs the app even if it is already installed on your Mac.

```console
$ mas install 497799835
==> Downloading Xcode
==> Installed Xcode
```

</details>
<details>
<summary>

#### `mas lucky`

</summary>

`mas lucky <search-term>` installs the first result that would be returned by `mas search <search-term>`. Like
`mas install`, `mas lucky` can only install apps that have previously been gotten or purchased.

```console
$ mas lucky Xcode
==> Downloading Xcode
==> Installed Xcode
```

</details>
</details>
<details>
<summary>

### 🆕 Upgrading apps

</summary>

All the commands in this section require you to be logged into an Apple Account in the Mac App Store.

> mas only installs/updates applications from the Mac App Store.
>
> Use [`softwareupdate(8)`](https://www.unix.com/man-page/osx/8/softwareupdate) to install system updates (e.g., Xcode
> Command Line Tools, Safari, etc.)

<details>
<summary>

#### `mas update`

</summary>

`mas update` updates outdated apps installed from the Mac App Store. Without any arguments, it updates all such apps.

```console
$ mas update
Upgrading 2 outdated applications:
Xcode (15.4) -> (16.0)
Developer (10.6.5) -> (10.6.6)
==> Downloading Xcode
==> Installed Xcode
==> Downloading Developer
==> Installed Developer
```

Updates can be performed selectively by providing app IDs to `mas update`.

```console
$ mas update 715768417
Upgrading 1 outdated application:
Xcode (15.4) -> (16.0)
==> Downloading Xcode
==> Installed Xcode
```

</details>
</details>
<details>
<summary>

### 🪪 Mac App Store account management

</summary>

All the commands in this section interact with the Apple Account for which you are signed in to the Mac App Store. These
commands do not interact with the Apple Account for which your macOS user is signed in.

<details>
<summary>

#### `mas signin`

</summary>

> ⛔ The `signin` command is not supported on macOS 10.13 (High Sierra) or newer. On those macOS versions, please sign in
> via the Mac App Store instead. Please see [Known Issues](#️-known-issues).

On macOS 10.12 (Sierra) or older, `mas signin <apple-id>` signs in to the specified Apple Account in the Mac App Store.

```console
$ mas signin mas@example.com
Password:
```

Providing the `--dialog` flag signs in using a graphical dialog provided by Mac App Store.

```shell
mas signin --dialog mas@example.com
```

You can also embed your password in the command.

```shell
mas signin mas@example.com MyPassword
```

</details>
<details>
<summary>

#### `mas signout`

</summary>

`mas signout` signs out from the current Apple Account in the Mac App Store.

</details>
</details>
</details>
<details>
<summary>

## 🧩 Integrations

</summary>
<details>
<summary>

### 🍻 Homebrew Bundle

</summary>

If mas is installed:

- When you run `brew bundle dump`, your Mac App Store apps will be included in the generated `Brewfile`.
- When you run Homebrew Bundle commands on a `Brewfile` that contains Mac App Store apps, they will be processed by the
  command.

See the [Homebrew Bundle documentation](https://docs.brew.sh/Brew-Bundle-and-Brewfile) for more details.

</details>
<details>
<summary>

### ⚙️ Topgrade

</summary>

If mas is installed, when you run [Topgrade](https://github.com/topgrade-rs/topgrade), your Mac App Store apps will be
updated.

</details>
</details>
<details>
<summary>

## ⚠️ Known issues

</summary>
<details>
<summary>

### 💥 Broken Apple private frameworks

</summary>

mas uses multiple undocumented Apple private frameworks to implement much of its functionality.

Over time, Apple has silently changed these frameworks, breaking some functionality, including:

- ⛔ The `signin` command is not supported on macOS 10.13 (High Sierra) or newer.
  [#164](https://github.com/mas-cli/mas/issues/164)
- ⛔ The `account` command is not supported on macOS 12 (Monterey) or newer
  [#417](https://github.com/mas-cli/mas/issues/417)

</details>
<details>
<summary>

### ⏳ Eventual consistency

</summary>

The Mac App Store operates on eventual consistency.

The versions seen by various parts of mas or the Mac App Store might be inconsistent for days
([#384](https://github.com/mas-cli/mas/issues/384) & [#387](https://github.com/mas-cli/mas/issues/387)).

</details>
<details>
<summary>

### 📱 iOS & iPadOS apps

</summary>

Apple Silicon Macs can install iOS & iPadOS apps from the Mac App Store.

mas does not yet support such apps ([#321](https://github.com/mas-cli/mas/issues/321)).

</details>
<details>
<summary>

### 📺 `tmux`

</summary>

mas depends on the same XPC system services as the Mac App Store.

mas thus experiences similar problems as the pasteboard when running inside `tmux`.

This [wrapper](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) allows pasteboard & mas to work inside `tmux`.

`tmux` can be configured to always use the wrapper.

Alternatively, the wrapper can be used on a one-off basis:

```shell
brew install reattach-to-user-namespace
reattach-to-user-namespace mas install
```

</details>
<details>
<summary>

### 🤷 Undetected installed apps

</summary>

mas 2.0.0+ sources data for installed Mac App Store apps from macOS's Spotlight Metadata Server (aka MDS).

You can check if a Mac App Store app is properly indexed in the MDS:

```console
## General format:
$ mdls -rn kMDItemAppStoreAdamID <path-to-app>
## Outputs the ADAM ID if the app is indexed
## Outputs nothing if the app is not indexed

## Example:
$ mdls -rn kMDItemAppStoreAdamID /Applications/WhatsApp.app
310633997
```

If an app has been indexed in the MDS, the path to the app can be found:

```shell
mdfind 'kMDItemAppStoreAdamID == <adam-id>'
```

If any of Mac App Store apps are not indexed, the MDS can be enabled/rebuilt for all file system volumes:

```shell
sudo mdutil -Eai on
```

</details>
</details>
<details>
<summary>

## ❗ Troubleshooting

</summary>
<details>
<summary>

### 🚫 Redownload not available

</summary>

If the following error occurs, you probably haven't yet gotten or purchased the app from the Mac App Store
([#46](https://github.com/mas-cli/mas/issues/46#issuecomment-248581233)).

> This redownload is not available for this Apple Account either because it was bought by a different user or the item
> was refunded or canceled.

</details>
<details>
<summary>

### ❓ Other issues

</summary>

If mas doesn't work as expected (e.g., apps can't be installed/updated), run `mas reset`, then try again.

If the issue persists, please [file a bug](https://github.com/mas-cli/mas/issues/new).

All feedback is much appreciated!

</details>
</details>
<details>
<summary>

## 🏗 Building

</summary>

mas can be built in Xcode or built by the following script:

```shell
Scripts/build
```

Build output can be found in the `.build` folder in the project's root folder.

</details>
<details>
<summary>

## 🧪 Testing

</summary>

Tests are implemented in [Swift Testing](https://github.com/swiftlang/swift-testing).

Tests can be run by the following script:

```shell
Scripts/test
```

</details>
<details>
<summary>

## 📄 License

</summary>

Code is under the [MIT license](LICENSE).

mas was originally created by Andrew Naylor ([@argon on GitHub](https://github.com/argon) /
[@argon on X](https://x.com/argon)).

</details>
