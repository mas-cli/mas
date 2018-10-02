# Testing OS X and iOS Applications

*[Setting Up Tests in Your Xcode Project](SettingUpYourXcodeProject.md)*
covers everything you need to know to test any Objective-C or Swift function or class.
In this section, we'll go over a few additional hints for testing
classes like `UIViewController` subclasses.

> You can see a short lightning talk covering most of these topics
  [here](https://vimeo.com/115671189#t=37m50s) (the talk begins at 37'50").

## Triggering `UIViewController` Lifecycle Events

Normally, UIKit triggers lifecycle events for your view controller as it's
presented within the app. When testing a `UIViewController`, however, you'll
need to trigger these yourself. You can do so in one of three ways:

1. Accessing `UIViewController.view`, which triggers things like `UIViewController.viewDidLoad()`.
2. Use `UIViewController.beginAppearanceTransition()` to trigger most lifecycle events.
3. Directly calling methods like `UIViewController.viewDidLoad()` or `UIViewController.viewWillAppear()`.

```swift
// Swift

import Quick
import Nimble
import BananaApp

class BananaViewControllerSpec: QuickSpec {
  override func spec() {
    var viewController: BananaViewController!
    beforeEach {
      viewController = BananaViewController()
    }

    describe(".viewDidLoad()") {
      beforeEach {
        // Method #1: Access the view to trigger BananaViewController.viewDidLoad().
        let _ =  viewController.view
      }

      it("sets the banana count label to zero") {
        // Since the label is only initialized when the view is loaded, this
        // would fail if we didn't access the view in the `beforeEach` above.
        expect(viewController.bananaCountLabel.text).to(equal("0"))
      }
    }

    describe("the view") {
      beforeEach {
        // Method #2: Triggers .viewDidLoad(), .viewWillAppear(), and .viewDidAppear() events.
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
      }
      // ...
    }

    describe(".viewWillDisappear()") {
      beforeEach {
        // Method #3: Directly call the lifecycle event.
        viewController.viewWillDisappear(false)
      }
      // ...
    }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;
#import "BananaViewController.h"

QuickSpecBegin(BananaViewControllerSpec)

__block BananaViewController *viewController = nil;
beforeEach(^{
  viewController = [[BananaViewController alloc] init];
});

describe(@"-viewDidLoad", ^{
  beforeEach(^{
    // Method #1: Access the view to trigger -[BananaViewController viewDidLoad].
    [viewController view];
  });

  it(@"sets the banana count label to zero", ^{
    // Since the label is only initialized when the view is loaded, this
    // would fail if we didn't access the view in the `beforeEach` above.
    expect(viewController.bananaCountLabel.text).to(equal(@"0"))
  });
});

describe(@"the view", ^{
  beforeEach(^{
    // Method #2: Triggers .viewDidLoad(), .viewWillAppear(), and .viewDidAppear() events.
    [viewController beginAppearanceTransition:YES animated:NO];
    [viewController endAppearanceTransition];
  });
  // ...
});

describe(@"-viewWillDisappear", ^{
  beforeEach(^{
    // Method #3: Directly call the lifecycle event.
    [viewController viewWillDisappear:NO];
  });
  // ...
});

QuickSpecEnd
```

## Initializing View Controllers Defined in Storyboards

To initialize view controllers defined in a storyboard, you'll need to assign
a **Storyboard ID** to the view controller:

![](http://f.cl.ly/items/2X2G381K1h1l2B2Q0g3L/Screen%20Shot%202015-02-27%20at%2011.58.06%20AM.png)

Once you've done so, you can instantiate the view controller from within your tests:

```swift
// Swift

var viewController: BananaViewController!
beforeEach {
  // 1. Instantiate the storyboard. By default, it's name is "Main.storyboard".
  //    You'll need to use a different string here if the name of your storyboard is different.
  let storyboard = UIStoryboard(name: "Main", bundle: nil)
  // 2. Use the storyboard to instantiate the view controller.
  viewController = 
    storyboard.instantiateViewControllerWithIdentifier(
      "BananaViewControllerID") as! BananaViewController
}
```

```objc
// Objective-C

__block BananaViewController *viewController = nil;
beforeEach(^{
  // 1. Instantiate the storyboard. By default, it's name is "Main.storyboard".
  //    You'll need to use a different string here if the name of your storyboard is different.
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  // 2. Use the storyboard to instantiate the view controller.
  viewController = [storyboard instantiateViewControllerWithIdentifier:@"BananaViewControllerID"];
});
```

## Triggering UIControl Events Like Button Taps

Buttons and other UIKit classes inherit from `UIControl`, which defines methods
that allow us to send control events, like button taps, programmatically.
To test behavior that occurs when a button is tapped, you can write:

```swift
// Swift

describe("the 'more bananas' button") {
  it("increments the banana count label when tapped") {
    viewController.moreButton.sendActionsForControlEvents(
      UIControlEvents.TouchUpInside)
    expect(viewController.bananaCountLabel.text).to(equal("1"))
  }
}
```

```objc
// Objective-C

describe(@"the 'more bananas' button", ^{
  it(@"increments the banana count label when tapped", ^{
    [viewController.moreButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    expect(viewController.bananaCountLabel.text).to(equal(@"1"));
  });
});
```

## Waiting for Asynchronous Operations with XCTestExpectation

Tests sometimes need to wait for apps to complete operations such as animations and network calls that run asynchronously, either on a background queue or on a separate turn of the main run loop. (Aside: note that in most cases, tests should stub network calls and not actually use the network.)

The standard XCTest way of handling asynchronous operations is to use [expectations](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html#//apple_ref/doc/uid/TP40014132-CH4-SW6). Quick supports these, but be careful! **Do not use `self` to get an instance of `XCTest`**. This includes creating or waiting for XCTest expectations:

```swift
it("makes a network call") {
    // 🛑 WRONG: don’t use self.expectation in Quick
    let expectation = self.expectation(description: "network call")
    URLSession.shared.dataTask(with: URL(string: "https://example.com")!) {
        _ in expectation.fulfill()
    }.resume()
    // 🛑 WRONG: don’t use self.waitForExpectations in Quick
    self.waitForExpectations(timeout: 1)
}
```

Why is this bad? Because when Quick runs your `spec()` function, it runs it on a dummy instance of `XCTest`. The real `XCTest` does not appear until those `it` closures actually run. In your `it` closures, `self` captures that dummy instance. Using this dummy instance to work with expectations is broken in two ways:

- It sometimes fails with a “Questionable API usage” or “API violation” error.
- Sometimes it _appears_ to work, but even then it bypasses XCTest’s checks for common mistakes such as forgetting to call `waitForExpectations()`.

The solution is to use `QuickSpec.current`, which returns the currently executing instance of XCTest:

```swift
// Swift

it("makes a network call") {
    let expectation = QuickSpec.current.expectation(description: "network call")
    URLSession.shared.dataTask(with: URL(string: "https://example.com")!) {
        _ in expectation.fulfill()
    }.resume()
    QuickSpec.current.waitForExpectations(timeout: 1)
}
```

```objc
// Objective-C

it(@"makes a network call", ^{
    XCTestExpectation *expectation = [QuickSpec.current expectationWithDescription:@"network call"];
    NSURLSessionTask *task = [NSURLSession.sharedSession
        dataTaskWithURL: [NSURL URLWithString:@"https://example.com"]
        completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            [expectation fulfill];
        }];
    [task resume];
    [QuickSpec.current waitForExpectationsWithTimeout:1 handler:NULL];
});
```

### Nimble Alternative

Nimble’s `expect(…).toEventually(…)` can also help test asynchronous operations:

```swift
it("makes a network call") {
  var networkCallCompleted = false
  URLSession.shared.dataTask(with: URL(string: "https://example.com")!) {
      _ in networkCallCompleted = true
  }.resume()
  expect(networkCallCompleted).toEventually(beTrue())
}
```

This approach has several drawbacks:

- It is not thread safe. You have to do your own synchronization if the condition you’re testing for isn’t fulfilled on the main thread.
- It provides no sanity checking for unwaited conditions.
- It can’t aggregate multiple expectations in a single wait.
- It is slower, because `fulfill` immediately triggers success whereas `toEventually()` polls for it.

However, `toEventually()` can lead to simpler test code, and may be a better choice when these concerns do not apply.
