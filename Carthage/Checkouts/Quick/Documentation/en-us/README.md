# Documentation

Quick helps you verify how your Swift and Objective-C programs behave.
Doing so effectively isn't just a matter of knowing how to use Quick,
however. The guides in this directory can help you write
effective tests--not just using Quick, but even XCTest or other testing
frameworks.

Each guide covers a particular topic. If you're completely new to unit
testing, consider reading them in the order they're introduced below:

- **[Setting Up Tests in Your Xcode Project](SettingUpYourXcodeProject.md)**:
  Read this if you're having trouble using your application code from within
  your test files.
- **[Effective Tests Using XCTest: Arrange, Act, and Assert](ArrangeActAssert.md)**:
  Read this to learn how to write `XCTestCase` tests that will help you write
  code faster and more effectively.
- **[Don't Test Code, Instead Verify Behavior](BehavioralTesting.md)**:
  Read this to learn what kinds of tests speed you up, and which ones will only end up
  slowing you down.
- **[Clearer Tests Using Nimble Assertions](NimbleAssertions.md)**:
  Read this to learn how to use Nimble to generate better failure messages.
  Better failure messages help you move faster, by spending less time figuring out why
  a test failed.
- **[Organized Tests with Quick Examples and Example Groups](QuickExamplesAndGroups.md)**:
  Read this to learn how Quick can help you write even more effective tests, using
  *examples* and *example groups*.
- **[Testing OS X and iOS Applications](TestingApps.md)**:
  Read this to learn more about testing code that uses the AppKit and UIKit frameworks.
- **[Testing with test doubles](TestUsingTestDoubles.md)**:
  Read this to learn what test doubles are and how to use them.
- **[Reducing Test Boilerplate with Shared Assertions](SharedExamples.md)**:
  Read this to learn how to share sets of assertions among your tests.
- **[Configuring How Quick Behaves](ConfiguringQuick.md)**:
  Read this to learn how you can change how Quick behaves when running your test suite.
- **[Using Quick in Objective-C](QuickInObjectiveC.md)**:
  Read this if you experience trouble using Quick in Objective-C.
- **[Installing Quick](InstallingQuick.md)**:
  Read this for instructions on how to add Quick to your project, using
  Git submodules, CocoaPods, Carthage, or the Swift Package Manager.
- **[Installing Quick File Templates](InstallingFileTemplates.md)**:
  Read this to learn how to install file templates that make writing Quick specs faster.
- **[More Resources](MoreResources.md)**:
  A list of additional resources on OS X and iOS testing.
- **[Troubleshooting](Troubleshooting.md)**:
  Read this when you experience other troubles.
