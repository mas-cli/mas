![](http://f.cl.ly/items/0r1E192C1R0b2g2Q3h2w/QuickLogo_Color.png)

[![Build Status](https://travis-ci.org/Quick/Quick.svg?branch=master)](https://travis-ci.org/Quick/Quick)
[![CocoaPods](https://img.shields.io/cocoapods/v/Quick.svg)](https://cocoapods.org/pods/Quick)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platforms](https://img.shields.io/cocoapods/p/Quick.svg)](https://cocoapods.org/pods/Quick)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

Quick is a behavior-driven development framework for Swift and Objective-C.
Inspired by [RSpec](https://github.com/rspec/rspec), [Specta](https://github.com/specta/specta), and [Ginkgo](https://github.com/onsi/ginkgo).

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/QuickSpec%20screenshot.png)

```swift
// Swift

import Quick
import Nimble

class TableOfContentsSpec: QuickSpec {
  override func spec() {
    describe("the 'Documentation' directory") {
      it("has everything you need to get started") {
        let sections = Directory("Documentation").sections
        expect(sections).to(contain("Organized Tests with Quick Examples and Example Groups"))
        expect(sections).to(contain("Installing Quick"))
      }

      context("if it doesn't have what you're looking for") {
        it("needs to be updated") {
          let you = You(awesome: true)
          expect{you.submittedAnIssue}.toEventually(beTruthy())
        }
      }
    }
  }
}
```
#### Nimble
Quick comes together with [Nimble](https://github.com/Quick/Nimble) — a matcher framework for your tests. You can learn why `XCTAssert()` statements make your expectations unclear and how to fix that using Nimble assertions [here](./Documentation/en-us/NimbleAssertions.md).

## Swift Version

Certain versions of Quick and Nimble only support certain versions of Swift. Depending on which version of Swift your project uses, you should use specific versions of Quick and Nimble. Use the table below to determine which versions of Quick and Nimble are compatible with your project.

|Swift version        |Quick version   |Nimble version |
|:--------------------|:---------------|:--------------|
|Swift 4.2            |v1.3.2 or later |v7.3.2 or later|
|Swift 3 / Swift 4    |v1.0.0 or later |v5.0.0 or later|
|Swift 2.2 / Swift 2.3|v0.9.3          |v4.1.0         |

## Documentation

All documentation can be found in the [Documentation folder](./Documentation), including [detailed installation instructions](./Documentation/en-us/InstallingQuick.md) for CocoaPods, Carthage, Git submodules, and more. For example, you can install Quick and [Nimble](https://github.com/Quick/Nimble) using CocoaPods by adding the following to your Podfile:

```rb
# Podfile

use_frameworks!

target "MyApp" do
  # Normal libraries

  abstract_target 'Tests' do
    inherit! :search_paths
    target "MyAppTests"
    target "MyAppUITests"

    pod 'Quick'
    pod 'Nimble'
  end
end
```

## Projects using Quick

Over ten-thousand apps use either Quick and Nimble however, as they are not included in the app binary, neither appear in “Top Used Libraries” blog posts. Therefore, it would be greatly appreciated to remind contributors that their efforts are valued by compiling a list of organizations and projects that use them. 

Does your organization or project use Quick and Nimble? If yes, [please add your project to the list](https://github.com/Quick/Quick/wiki/Projects-using-Quick).

## Who uses Quick

Similar to projects using Quick, it would be nice to hear why people use Quick and Nimble. Are there features you love? Are there features that are just okay? Are there some features we have that no one uses?

Have something positive to say about Quick (or Nimble)? If yes, [provide a testimonial here](https://github.com/Quick/Quick/wiki/Who-uses-Quick).


## License

Apache 2.0 license. See the [`LICENSE`](LICENSE) file for details.
