<h1 align="center"><img src="mas-cli.png" alt="mas-cli" width="450" height="138"></h1>

# mas

A command-line interface for the Mac App Store. Designed for scripting and automation.

[![GitHub Release](https://img.shields.io/github/release/mas-cli/mas.svg)](https://github.com/mas-cli/mas/releases)
[![Software License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](
    https://github.com/mas-cli/mas/blob/main/LICENSE
)
[![Swift 5](https://img.shields.io/badge/Language-Swift_5-orange.svg)](https://swift.org)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Build, Test, & Lint](https://github.com/mas-cli/mas/actions/workflows/build-test.yml/badge.svg?branch=main)](
    https://github.com/mas-cli/mas/actions/workflows/build-test.yml?query=branch%3Amain
)

## 📲 Installation

### 🍺 Homebrew

[Homebrew](http://brew.sh) is the preferred way to install:

```shell
brew install mas
```

⚠️ macOS 10.15 (Catalina) or newer is required to install mas from the Homebrew core formula.

### 🔌 MacPorts

[MacPorts](https://www.macports.org/install.php) is an alternative way to install:

```shell
sudo port install mas
```

⚠️ macOS 10.15 (Catalina) or newer is required to install mas from MacPorts.

### ☎️ Older macOS Versions

#### 🍻 Custom Homebrew tap

We provide a [custom Homebrew tap](https://github.com/mas-cli/homebrew-tap) with pre-built bottles
for all macOS versions since 10.11 (El Capitan). The newest versions of mas, however, are only available
for macOS 10.13+ (High Sierra or newer).

To install mas from our tap:

```shell
brew install mas-cli/tap/mas
```

#### 🐙 GitHub Releases

Alternatively, binaries and sources are available from the [GitHub Releases](https://github.com/mas-cli/mas/releases).

#### 🕊 Swift 5 Runtime Support

mas requires Swift 5 runtime support. macOS 10.14.4 (Mojave) and newer include it, but earlier releases do not.
Without it, running mas might report errors similar to:
> dyld: Symbol not found: _$s11SubSequenceSlTl

To get Swift 5 support on macOS versions older than 10.14.4 (Mojave), you can:

- Upgrade to macOS 10.14.4 (Mojave) or newer.
- Install the [Swift 5 Runtime Support for Command Line Tools](https://support.apple.com/kb/DL1998).
- Install Xcode 10.2 or newer to `/Applications/Xcode.app`.

## 🤳🏻 Usage

### 🪪 App IDs

Each application in the Mac App Store has an integer app identifier (app ID).
mas commands accept app IDs as arguments and output App IDs to uniquely identify apps.

`mas search` and `mas list` can be used to find the app IDs of relevant apps.

Alternatively, to find an app's app ID:

1. Find the app in the Mac App Store
2. Select `Share` > `Copy Link`
3. Extract the app ID from the URL. e.g., the Mac App Store URL for Xcode,
   [https://apps.apple.com/us/app/xcode/id497799835?mt=12](https://apps.apple.com/us/app/xcode/id497799835?mt=12),
   has app ID `497799835`

### 🛍 Info from the Mac App Store

None of the commands in this section require you to be logged into an Apple ID,
neither for your macOS user, nor in the Mac App Store.

#### `mas search`

`mas search <search-term>` searches by name for applications available from the Mac App Store.
Providing the `--price` flag includes each app's price in the output.

```console
$ mas search Xcode
497799835 Xcode
688199928 Docs for Xcode
449589707 Dash 3 - API Docs & Snippets. Integrates with Xcode, Alfred, TextWrangler and many more.
[...]
```

#### `mas info`

`mas info <app-id>` displays more detailed information about an application available from the Mac App Store.

```console
$ mas info 497799835
Xcode 16.0 [0.0]
By: Apple Inc.
Released: 2024-09-16
Minimum OS: 14.5
Size: 2.98 GB
From: https://apps.apple.com/us/app/xcode/id497799835?mt=12&uo=4
```

### 📚 Info from Your Local App Library

All the commands in this section require you to be logged into an Apple ID for your macOS user.

#### `mas list`

`mas list` displays all the applications on your Mac that were installed from the Mac App Store.

```console
$ mas list
497799835 Xcode       (15.4)
640199958 Developer   (10.6.5)
899247664 TestFlight  (3.5.2)
```

#### `mas outdated`

`mas outdated` displays all applications installed from the Mac App Store on your computer that have pending upgrades.

```console
$ mas outdated
497799835 Xcode (15.4 -> 16.0)
640199958 Developer (10.6.5 -> 10.6.6)
```

Run [`mas upgrade`](#mas-upgrade) to install pending upgrades.

### ⬇️ Installing Apps

All the commands in this section require you to be logged into an Apple ID in the Mac App Store.

> Depending on your Apple ID settings, you might need to re-authenticate yourself in the Mac App Store to perform a
> purchase, install, lucky, or upgrade, even if you are already signed in to an Apple ID in the Mac App Store.

#### `mas purchase`

`mas purchase <app-id>…` installs free applications that you haven't yet gotten/"purchased" from the Mac App Store.

> `purchase` is currently a misnomer, because it currently can only "purchase" free
> apps. To purchase apps that cost money, please purchase them directly in the Mac App Store.

```console
$ mas purchase 497799835
==> Downloading Xcode
==> Installed Xcode
```

#### `mas install`

`mas install <app-id>…` installs apps that you have already gotten/"purchased" from the Mac App Store.
Providing the `--force` flag re-installs the app even if it is already installed on your computer.

```console
$ mas install 497799835
==> Downloading Xcode
==> Installed Xcode
```

#### `mas lucky`

`mas lucky <search-term>` installs the first result that would be returned by `mas search <search-term>`.
Like `mas install`, `mas lucky` can only install apps that have previously been gotten/"purchased".

```console
$ mas lucky Xcode
==> Downloading Xcode
==> Installed Xcode
```

### 🆕 Upgrading Apps

All the commands in this section require you to be logged into an Apple ID in the Mac App Store.

> mas only installs/upgrades applications from the Mac App Store.
Use [`softwareupdate(8)`] to install system updates (e.g., Xcode Command Line Tools, Safari, etc.)

#### `mas upgrade`

`mas upgrade` upgrades outdated apps installed from the Mac App Store. Without any arguments, it upgrades all such apps.

```console
$ mas upgrade
Upgrading 2 outdated applications:
Xcode (15.4) -> (16.0)
Developer (10.6.5) -> (10.6.6)
==> Downloading Xcode
==> Installed Xcode
==> Downloading Developer
==> Installed Developer
```

Upgrades can be performed selectively by providing app IDs to `mas upgrade`.

```console
$ mas upgrade 715768417
Upgrading 1 outdated application:
Xcode (15.4) -> (16.0)
==> Downloading Xcode
==> Installed Xcode
```

### Mac App Store Account Management

All the commands in this section interact with the Apple ID for which you are signed in in the Mac App Store.
These commands do not interact with the Apple ID for which your macOS user is signed in.

#### `mas signin`

> ⛔ The `signin` command is not supported on macOS 10.13 (High Sierra) or newer. On those macOS versions, please
> sign in via the Mac App Store instead. Please see [Known Issues](#known-issues).

On macOS 10.12 (Sierra) or older, `mas signin <apple-id>` signs in to the specified Apple ID in the Mac App Store.

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

#### `mas signout`

`mas signout` signs out from the current Apple ID in the Mac App Store.

## 🍺 Homebrew integration

mas integrates with [homebrew-bundle]. If mas is installed, when you run `brew bundle dump`,
your Mac App Store apps will be included in the created Brewfile. See the [homebrew-bundle]
docs for more details.

<!-- markdownlint-disable-next-line MD033 -->
## <a name="known-issues"></a> ⚠️ Known Issues

### 💥 Changed Apple Private Frameworks

mas uses multiple undocumented Apple private frameworks to implement much of its functionality.
Over time, Apple has silently changed these frameworks, breaking some functionality. Known issues include:

- ⛔️ The `signin` command is not supported on macOS 10.13 (High Sierra) or newer. [#164](
      https://github.com/mas-cli/mas/issues/164
  )
- ⛔️ The `account` command is not supported on macOS 12 (Monterey) or newer. [#417](
      https://github.com/mas-cli/mas/issues/417
  )

### 👀 Version Consistency

mas might be using suboptimal app version sources to compare local app versions with Mac App Store app versions.
That current sources are frequently consistent with the Mac App Store, but are infrequently inconsistent.
This might cause symptoms like [#384](https://github.com/mas-cli/mas/issues/384) and
[#387](https://github.com/mas-cli/mas/issues/387). mas will be updated soon to fix any such problems, if possible.

### ⏳ Eventual Consistency

The Mac App Store operates on eventual consistency, so the versions seen by various parts of mas or the Mac App Store
might be inconsistent for some period of time. This might cause symptoms like
[#384](https://github.com/mas-cli/mas/issues/384) and [#387](https://github.com/mas-cli/mas/issues/387).

### 📱 iOS and iPadOS Apps

Macs with Apple Silicon can install and run iOS and iPadOS apps from the Mac App Store. mas is not yet aware of these
apps, and is not yet able to install or upgrade them. [#321](https://github.com/mas-cli/mas/issues/321)

### 📺 Using `tmux`

mas operates via the same system services as the Mac App Store. These exist as
separate processes with communication through XPC. As a result of this, mas
experiences similar problems as the pasteboard when running inside `tmux`. A
[wrapper tool exists](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) to
fix pasteboard behaviour which also works for mas.

You should consider configuring `tmux` to use the wrapper but if you do not wish
to do this it can be used on a one-off basis as follows:

```shell
brew install reattach-to-user-namespace
reattach-to-user-namespace mas install
```

## 🚫 When something doesn't work

If you see the following error, it's probably because you haven't yet "purchased" the app through the Mac App Store.
See [#46](https://github.com/mas-cli/mas/issues/46#issuecomment-248581233).
> This redownload is not available for this Apple ID either because it was bought by a different user or the
> item was refunded or cancelled.

If mas doesn't work for you as expected (e.g. you can't install/upgrade apps), run `mas reset`, then try again.
If the issue persists, please [file a bug](https://github.com/mas-cli/mas/issues/new).
All feedback is much appreciated! ✨

## ℹ️ Build from source

You can build from Xcode by opening the root mas directory, or from the Terminal:

```shell
script/bootstrap
script/build
```

Build output can be found in the `.build/` directory within the project.

## ✅ Tests

The tests in this project are a recent work-in-progress.
Since Xcode does not officially support tests for command-line tool targets,
all logic is part of the mas target with tests in masTests.
Tests are written using [Quick].

```shell
script/test
```

## 📄 License

mas was created by [@argon](https://github.com/argon).
Code is under the [MIT license](LICENSE).

[homebrew-bundle]: https://github.com/Homebrew/homebrew-bundle
[`softwareupdate(8)`]: https://www.unix.com/man-page/osx/8/softwareupdate/
[Quick]: https://github.com/Quick/Quick
