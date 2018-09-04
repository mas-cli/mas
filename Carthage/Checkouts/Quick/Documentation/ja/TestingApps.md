# Testing OS X and iOS Applications

*[Xcodeでテストを用意しましょう](SettingUpYourXcodeProject.md)*では Objective-C や Swift の関数やクラスを
テストするために必要なことを述べました。ここでは `UIViewController` のサブクラスなどをテストする際のポイントを述べます。

> 関連する LT がありますので[こちら](https://vimeo.com/115671189#t=37m50s)も参考にしてください。 (37'50" から始まる部分です)。

## `UIViewController` のライフサイクルイベントを発火させる

通常は UIKit が view controller のライフサイクルイベントを発火しますが、
テストをする時は自分たちでライフサイクルイベントを発火させる必要があります。
呼び出すには３つの方法があります。

1. `UIViewController.view`にアクセスする、すると `UIViewController.viewDidLoad()` のイベントが発火します。
2. `UIViewController.beginAppearanceTransition()` を呼び出すとほとんどのライフサイクルイベントが発火します。。
3. `UIViewController.viewDidLoad()` や `UIViewController.viewWillAppear()` などのライフサイクルに関わる関数を直接呼び出す。

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

## Storyboard 内に定義した View Controller を初期化する

Storyboard 内に定義した View Controller を初期化する際は **Storyboard ID** を定義しておく必要があります。

![](http://f.cl.ly/items/2X2G381K1h1l2B2Q0g3L/Screen%20Shot%202015-02-27%20at%2011.58.06%20AM.png)

**Storyboard ID** を定義しておくとテストコードから ViewController を初期化することができます。

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

## ボタンをタップされた、などの UIControl Events を発火させる

ボタンや他の `UIControl` を継承したクラスは Control イベントを発火させる関数を持っています。
ボタンをタップされた時の動作をテストするにはこのように書くことができます：

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
