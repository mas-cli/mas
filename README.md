<h1 align="center"><img src="mas-cli.png" alt="mas-cli" width="450" height="auto"></h1>

# mas-cli

A simple command line interface for the Mac App Store. Designed for scripting and automation.

[![Software License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/mas-cli/mas/blob/main/LICENSE)
[![Swift 5](https://img.shields.io/badge/Language-Swift_5-orange.svg)](https://swift.org)
[![GitHub Release](https://img.shields.io/github/release/mas-cli/mas.svg)](https://github.com/mas-cli/mas/releases)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Build, Test, & Lint](https://github.com/mas-cli/mas/actions/workflows/build-test.yml/badge.svg?branch=main)](https://github.com/mas-cli/mas/actions/workflows/build-test.yml?query=branch%3Amain)

## 📲 Install

### 🍺 Homebrew

[Homebrew](http://brew.sh) is the preferred way to install:

```bash
brew install mas
```

### MacPorts

[MacPorts](https://www.macports.org/install.php) works as well:

```bash
sudo port install mas
```

⚠️ Note that macOS 10.15 (Catalina) is required to install mas from MacPorts or the core Homebrew formula.

### ☎️ Older macOS Versions

We provide a [custom Homebrew tap](https://github.com/mas-cli/homebrew-tap) with pre-built bottles
for all macOS versions since 10.11.

To install mas from our tap:

```bash
brew install mas-cli/tap/mas
```

#### Swift 5 Runtime Support

mas requires Swift 5 runtime support. macOS 10.14.4 and later include it, but earlier releases did not.
Without it, running `mas` may report an error similar to this:
> dyld: Symbol not found: _$s11SubSequenceSlTl

To get Swift 5 support, you have a few options:

- Install the [Swift 5 Runtime Support for Command Line Tools](https://support.apple.com/kb/DL1998).
- Update to macOS 10.14.4 or later.
- Install Xcode 10.2 or later to `/Applications/Xcode.app`.

### 🐙 GitHub Releases

Alternatively, binaries are available in the [GitHub Releases](https://github.com/mas-cli/mas/releases).

## 🤳🏻 Usage

Each application in the Mac App Store has a product identifier which is also
used for mas-cli commands. Using `mas list` will show all installed
applications and their product identifiers.

```bash
$ mas list
446107677 Screens
407963104 Pixelmator
497799835 Xcode
```

It is possible to search for applications by name using `mas search` which
will search the Mac App Store and return matching identifiers.
Include the `--price` flag to include prices in the result.

```bash
$ mas search Xcode
497799835 Xcode
688199928 Docs for Xcode
449589707 Dash 3 - API Docs & Snippets. Integrates with Xcode, Alfred, TextWrangler and many more.
[...]
```

Another way to find the identifier for an app is to

1. Find the app in the Mac App Store
2. Select `Share` > `Copy Link`
3. Grab the identifier from the string, e.g. for Xcode,
   [https://apps.apple.com/us/app/xcode/id497799835?mt=12](https://apps.apple.com/us/app/xcode/id497799835?mt=12)
   has identifier `497799835`

To install or update an application simply run `mas install` with an
application identifier:

```bash
$ mas install 808809998
==> Downloading PaintCode 2
==> Installed PaintCode 2
```

If you want to install the first result that the `search` command returns, use the `lucky` command.

```bash
$ mas lucky twitter
==> Downloading Twitter
==> Installed Twitter
```

> Please note that this command will not allow you to install (or even purchase) an app for the first time:
use the `purchase` command in that case.
> ⛔ The `purchase` command is not supported as of macOS 10.15 Catalina. Please see [Known Issues](#%EF%B8%8F-known-issues).

```bash
$ mas purchase 768053424
==> Downloading Gapplin
==> Installed Gapplin
```

> Please note that you may have to re-authenticate yourself in the App Store to complete the purchase.
This is the case if the application is not free or if you configured your account not to remember the
credentials for free purchases.

Use `mas outdated` to list all applications with pending updates.

```bash
$ mas outdated
497799835 Xcode (7.0)
446107677 Screens VNC - Access Your Computer From Anywhere (3.6.7)
```

> `mas` is only able to install/update applications that are listed in the Mac App Store itself.
Use [`softwareupdate(8)`] utility for downloading system updates (e.g. Xcode Command Line Tools)

To install all pending updates run `mas upgrade`.

```bash
$ mas upgrade
Upgrading 2 outdated applications:
Xcode (7.0), Screens VNC - Access Your Computer From Anywhere (3.6.7)
==> Downloading Xcode
==> Installed Xcode
==> Downloading iFlicks
==> Installed iFlicks
```

Updates can be performed selectively by providing the app identifier(s) to
`mas upgrade`

```bash
$ mas upgrade 715768417
Upgrading 1 outdated application:
Xcode (8.0)
==> Downloading Xcode
==> Installed Xcode
```

### 🚏📥 Sign-in

> ⛔ The `signin` command is not supported as of macOS 10.13 High Sierra. Please see [Known Issues](#%EF%B8%8F-known-issues).

To sign into the Mac App Store for the first time run `mas signin`.

```bash
$ mas signin mas@example.com
==> Signing in to Apple ID: mas@example.com
Password:
```

If you experience issues signing in this way, you can ask to sign in using a graphical dialog
(provided by Mac App Store application):

```bash
$ mas signin --dialog mas@example.com
==> Signing in to Apple ID: mas@example.com
```

You can also embed your password in the command.

```bash
$ mas signin mas@example.com 'ZdkM4f$gzF;gX3ABXNLf8KcCt.x.np'
==> Signing in to Apple ID: mas@example.com
```

Use `mas signout` to sign out from the Mac App Store.

## 🍺 Homebrew integration

`mas` is integrated with [homebrew-bundle]. If `mas` is installed, and you run `brew bundle dump`,
then your Mac App Store apps will be included in the Brewfile created. See the [homebrew-bundle]
docs for more details.

## ⚠️ Known Issues

Over time, Apple has changed the APIs used by `mas` to manage App Store apps, limiting its capabilities. Please sign in
or purchase apps using the App Store app instead. Subsequent redownloads can be performed with `mas install`.

- ⛔️ The `signin` command is not supported as of macOS 10.13 High Sierra. [#164](https://github.com/mas-cli/mas/issues/164)
- ⛔️ The `purchase` command is not supported as of macOS 10.15 Catalina. [#289](https://github.com/mas-cli/mas/issues/289)
- ⛔️ The `account` command is not supported as of macOS 12 Monterey. [#417](https://github.com/mas-cli/mas/issues/417)

The versions `mas` sees from the app bundles on your Mac don't always match the versions reported by the App Store for
the same app bundles. This leads to some confusion when the `outdated` and `upgrade` commands differ in behavior from
what is shown as outdated in the App Store app. Further confusing matters, there is often some delay due to CDN
propagation and caching between the time a new app version is released to the App Store, and the time it appears
available in the App Store app or via the `mas` command. These issues cause symptoms like
[#384](https://github.com/mas-cli/mas/issues/384) and [#387](https://github.com/mas-cli/mas/issues/387).

Macs with Apple silicon can install and run iOS and iPadOS apps from the App Store. `mas` is not yet aware of these
apps, and is not yet able to install or update them. [#321](https://github.com/mas-cli/mas/issues/321)

## 💥 When something doesn't work

If you see this error, it's probably because you haven't installed the app through the App Store yet.
See [#46](https://github.com/mas-cli/mas/issues/46#issuecomment-248581233).
> This redownload is not available for this Apple ID either because it was bought by a different user or the
> item was refunded or cancelled.

If `mas` doesn't work for you as expected (e.g. you can't update/download apps), run `mas reset` and try again.
If the issue persists, please [file a bug](https://github.com/mas-cli/mas/issues/new).
All your feedback is much appreciated! ✨

## 📺 Using `tmux`

`mas` operates via the same system services as the Mac App Store. These exist as
separate processes with communication through XPC. As a result of this, `mas`
experiences similar problems as the pasteboard when running inside `tmux`. A
[wrapper tool exists](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) to
fix pasteboard behaviour which also works for `mas`.

You should consider configuring `tmux` to use the wrapper but if you do not wish
to do this it can be used on a one-off basis as follows:

```bash
brew install reattach-to-user-namespace
reattach-to-user-namespace mas install
```

## ℹ️ Build from source

You can build from Xcode by opening the root `mas` directory, or from the Terminal:

```bash
script/bootstrap
script/build
```

Build output can be found in the `build/` directory within the project.

## ✅ Tests

The tests in this project are a recent work-in-progress.
Since Xcode does not officially support tests for command-line tool targets,
all logic is part of the MasKit target with tests in MasKitTests.
Tests are written using [Quick].

```bash
script/test
```

## 📄 License

mas-cli was created by [@argon](https://github.com/argon).
Code is under the [MIT license](LICENSE).

[homebrew-bundle]: https://github.com/Homebrew/homebrew-bundle
[mas-cli]: https://github.com/mas-cli/mas
[`softwareupdate(8)`]: https://www.unix.com/man-page/osx/8/softwareupdate/
[Quick]: https://github.com/Quick/Quick
