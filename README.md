[<p align="center"><img src="mas-cli.png" alt="mas-cli" width="450" height="auto"></p>][mas-cli]

# mas-cli

A simple command line interface for the Mac App Store. Designed for scripting and automation.

[![Build Status](https://travis-ci.com/mas-cli/mas.svg?branch=master)](https://travis-ci.com/mas-cli/mas)

## Install

[Homebrew](http://brew.sh) is the preferred way to install:

    brew install mas

Alternatively, binaries are available in the [GitHub Releases](https://github.com/mas-cli/mas/releases)

## Usage

Each application in the Mac App Store has a product identifier which is also
used for mas-cli commands. Using `mas list` will show all installed
applications and their product identifiers.

    $ mas list
    446107677 Screens
    407963104 Pixelmator
    497799835 Xcode

It is possible to search for applications by name using `mas search` which
will search the Mac App Store and return matching identifiers.
Include the `--price` flag to include prices in the result.

    $ mas search Xcode
    497799835 Xcode
    688199928 Docs for Xcode
    449589707 Dash 3 - API Docs & Snippets. Integrates with Xcode, Alfred, TextWrangler and many more.
    [...]

To install or update an application simply run `mas install` with an
application identifier:

    $ mas install 808809998
    ==> Downloading PaintCode 2
    ==> Installed PaintCode 2

If you want to install the first result that the `search` command returns, use the `lucky` command.

     $ mas lucky twitter
     ==> Downloading Twitter
     ==> Installed Twitter

> Please note that this command will not allow you to install (or even purchase) an app for the first time:
it must already be in the Purchased tab of the App Store.

Use `mas outdated` to list all applications with pending updates.

    $ mas outdated
    497799835 Xcode (7.0)
    446107677 Screens VNC - Access Your Computer From Anywhere (3.6.7)

> `mas` is only able to install/update applications that are listed in the Mac App Store itself.
Use [`softwareupdate(8)`](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/softwareupdate.8.html)
utility for downloading system updates (like iTunes, Xcode Command Line Tools, etc)

To install all pending updates run `mas upgrade`.

    $ mas upgrade
    Upgrading 2 outdated applications:
    Xcode (7.0), Screens VNC - Access Your Computer From Anywhere (3.6.7)
    ==> Downloading Xcode
    ==> Installed Xcode
    ==> Downloading iFlicks
    ==> Installed iFlicks

Updates can be performed selectively by providing the app identifier(s) to
`mas upgrade`

    $ mas upgrade 715768417
    Upgrading 1 outdated application:
    Xcode (8.0)
    ==> Downloading Xcode
    ==> Installed Xcode

### Signin

To sign into the Mac App Store for the first time run `mas signin`.

    $ mas signin mas@example.com
    ==> Signing in to Apple ID: mas@example.com
    Password:

> ⚠️ Due to breaking changes in the underlying API that mas uses to interact with the Mac App Store,
> the `signin` command has been temporarily disabled on macOS 10.13+ ⛔.
> For more information on this issue, see [#164](https://github.com/mas-cli/mas/issues/164).

If you experience issues signing in this way, you can ask to signin using a graphical dialog (provided by Mac App Store application):

     $ mas signin --dialog mas@example.com
     ==> Signing in to Apple ID: mas@example.com

You can also embed your password in the command.

    $ mas signin mas@example.com "ZdkM4f$gzF;gX3ABXNLf8KcCt.x.np"
    ==> Signing in to Apple ID: mas@example.com

Use `mas signout` to sign out from the Mac App Store.

## Homebrew integration

`mas` is integrated with [homebrew-bundle](https://github.com/Homebrew/homebrew-bundle). If `mas` is installed, and you run `brew bundle dump`,
then your Mac App Store apps will be included in the Brewfile created. See the [homebrew-bundle](https://github.com/Homebrew/homebrew-bundle)
docs for more details.

## When something doesn't work

If you see the error "This redownload is not available for this Apple ID either because it was bought by a different user of the item was refunded or cancelled.", it's probably because you haven't installed the app through the App Store yet. See [#46](https://github.com/mas-cli/mas/issues/46#issuecomment-248581233).

If `mas` doesn't work for you as expected (e.g. you can't update/download apps), run `mas reset` and try again. If the issue persists, please [file a bug](https://github.com/mas-cli/mas/issues/new)! All your feedback is much appreciated ✨

## Using `tmux`

`mas` operates via the same system services as the Mac App Store. These exist as
separate processes with communication through XPC. As a result of this, `mas`
experiences similar problems as the pasteboard when running inside `tmux`. A
[wrapper tool exists](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) to
fix pasteboard behaviour which also works for `mas`.

You should consider configuring `tmux` to use the wrapper but if you do not wish
to do this it can be used on a one-off basis as follows:

```
$ brew install reattach-to-user-namespace
$ reattach-to-user-namespace mas install
```

## Build from source

You can now build from Xcode by opening `mas-cli.xcodeproj`, or from the Terminal:

```
$ script/build
```

Build output can be found in the `build/` directory within the project.

## 🚧✅ Tests

The tests in this project are a work-in-progress. Since Xcode does not officially support tests for command-line tool targets, there is some strange behavior and manual actions necessary to create and/or update the tests:

- Types from the `mas` target must be included in the `mas-tests` target in order to be used in a test.
   - `@testable import mas` does not work
- XCTest is the current test framework
   - this may change in the future to Quick/Nimble.
- Code coverage doesn't show up for code under test until you enable "Show Test Bundles". Presumably, this is because production code is currently being added to two targets and Xcode is getting confused.

We may move the app code into a framework target to make it easier to test.

## License

mas-cli was created by [@argon](https://github.com/argon).
Code is under the [MIT license](LICENSE).

[mas-cli]: https://github.com/mas-cli/mas
