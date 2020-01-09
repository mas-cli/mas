# 使用 Shared Assertion 来复用测试模板代码

在某种场合下，一些特定的测试代码可以应用在不同的对象上。

比如，假设有一个叫 `Edible` 的协议。当一只海豚吃了标识为 `Edible` 的食物时，它会变得高兴。`Mackerel` 和 `Cod` 都遵循 `Edible` 协议。这个时候，Quick 的 shared example（共享用例）能帮你更容易地测试 `Mackerel` 和 `Cod` 的行为。

下面的例子为一些 `Edible` 的食物定义了一组共享用例，以测试 mackerel 和 cod 的行为。

```swift
// Swift

import Quick
import Nimble

class EdibleSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("something edible") { (sharedExampleContext: SharedExampleContext) in
      it("makes dolphins happy") {
        let dolphin = Dolphin(happy: false)
        let edible = sharedExampleContext()["edible"]
        dolphin.eat(edible)
        expect(dolphin.isHappy).to(beTruthy())
      }
    }
  }
}

class MackerelSpec: QuickSpec {
  override func spec() {
    var mackerel: Mackerel!
    beforeEach {
      mackerel = Mackerel()
    }

    itBehavesLike("something edible") { ["edible": mackerel] }
  }
}

class CodSpec: QuickSpec {
  override func spec() {
    var cod: Cod!
    beforeEach {
      cod = Cod()
    }

    itBehavesLike("something edible") { ["edible": cod] }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickConfigurationBegin(EdibleSharedExamplesConfiguration)

+ (void)configure:(Configuration *configuration) {
  sharedExamples(@"something edible", ^(QCKDSLSharedExampleContext exampleContext) {
    it(@"makes dolphins happy") {
      Dolphin *dolphin = [[Dolphin alloc] init];
      dolphin.happy = NO;
      id<Edible> edible = exampleContext()[@"edible"];
      [dolphin eat:edible];
      expect(dolphin.isHappy).to(beTruthy())
    }
  });
}

QuickConfigurationEnd

QuickSpecBegin(MackerelSpec)

__block Mackerel *mackerel = nil;
beforeEach(^{
  mackerel = [[Mackerel alloc] init];
});

itBehavesLike(@"someting edible", ^{ return @{ @"edible": mackerel }; });

QuickSpecEnd

QuickSpecBegin(CodSpec)

__block Mackerel *cod = nil;
beforeEach(^{
  cod = [[Cod alloc] init];
});

itBehavesLike(@"someting edible", ^{ return @{ @"edible": cod }; });

QuickSpecEnd
```

共享用例可以包括任意数量的 `it`， `context` 和 `describe` 代码块。当使用它们来测试不同对象的相同行为时，你可以少写*很多*不必要的重复代码。

一般来说，你使用共享用例进行测试时不需要依赖其他额外的对象。在 Swift 中，你可以简单地用一个不带参数的 `sharedExample` 闭包来使用共享用例。当你需要进行全局测试时，这很有用。

```swift
// Swift

import Quick

sharedExamples("everything under the sea") {
  // ...
}

itBehavesLike("everything under the sea")
```
> 如果你使用 Objective-C 的话，你需要传入一个带 `QCKDSLSharedExampleContext` 参数的 block，即使你并不打算使用它。不好意思，你只能这样做，人生有时就是这么的无奈。:cookie: :bomb:

你也可以使用 `fitBehavesLike` 函数来单独测试共享用例。
