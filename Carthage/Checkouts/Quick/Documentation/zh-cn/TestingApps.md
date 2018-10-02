# 测试 OS X 和 iOS 应用

*[在项目中添加测试](SettingUpYourXcodeProject.md)* 这篇文章详细介绍了有关如何测试 Objective-C 和 Swift 的函数和类的内容。
本文将介绍一些额外的技巧，用来测试**类**，如 `UIViewController` 及其子类。

> 你可以参考这个简短的 [Lightning Talk](https://vimeo.com/115671189#t=37m50s)（从37分50秒开始），它涵盖了绝大多数这方面的话题。

## 触发 `UIViewController` 生命周期事件

通常，当你的视图控制器（view controller）呈现在应用中，UIKit 会自动触发生命周期事件。然而，在测试 `UIViewController` 的时候，你需要自己手动触发这些事件。你可以通过以下任意一种方法来实现它：

1. 通过访问 `UIViewController.view` 来触发事件，如： `UIViewController.viewDidLoad()` 。
2. 使用 `UIViewController.beginAppearanceTransition()` 来触发大多数生命周期事件。
3. 直接调用方法，如：`UIViewController.viewDidLoad()` 或 `UIViewController.viewWillAppear()` 。

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

## 初始化在故事板（Storyboard）中定义的视图控制器

为了初始化在故事板中定义的视图控制器，你需要先为它分配一个 **Storyboard ID** ：

![](http://f.cl.ly/items/2X2G381K1h1l2B2Q0g3L/Screen%20Shot%202015-02-27%20at%2011.58.06%20AM.png)

为视图控制器分配 ID 后，就可以在测试中初始化了：

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

## 触发 UIControl 事件（如：点击按钮）

按钮以及其他继承自 `UIControl` 的 UIKit 类定义了一些方法，使我们能够通过程序代码发送控制事件，如：点击按钮。
以下代码演示了如何测试点击按钮触发的行为：

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


