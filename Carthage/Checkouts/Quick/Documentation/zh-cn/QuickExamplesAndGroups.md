# 用 Quick 例子和例子群组织测试

Quick 使用特殊的语法定义**例子（examples）**和**例子群（example groups）**。

在*[编写高效的 XCTest 测试: Arrange，Act 和 Assert](ArrangeActAssert.md)*，我们了解了一个好的测试方法名称是至关重要的，尤其是当测试失败时。它能够帮助我们判断是修改程序代码或者是更新测试内容。

Quick 的例子和例子群主要有两个目的：

1. 它们促使你使用具有描述性的测试名称。
2. 它们极大地简化了 Arrange 步骤的测试代码。

## 例子：使用 `it` 

定义了 `it` 函数的例子，使用断言代码指明了程序应有的行为。这些就像 XCTest 中的测试方法一样。

`it` 函数有两个参数：例子的名称和闭包。下面这个例子具体说明了 `Sea.Dolphin` 类应有的行为。
一只新的海豚（dolphin）应该是聪明（smart）且友好（friendly）的：

```swift
// Swift

import Quick
import Nimble
import Sea

class DolphinSpec: QuickSpec {
  override func spec() {
    it("is friendly") {
      expect(Dolphin().isFriendly).to(beTruthy())
    }

    it("is smart") {
      expect(Dolphin().isSmart).to(beTruthy())
    }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickSpecBegin(DolphinSpec)

it(@"is friendly", ^{
  expect(@([[Dolphin new] isFriendly])).to(beTruthy());
});

it(@"is smart", ^{
  expect(@([[Dolphin new] isSmart])).to(beTruthy());
});

QuickSpecEnd
```

用描述性的语言使例子所测试的内容清晰明了。
描述性的语言可以是任意长度、任意字符的，涵盖了英语以及其他语言的字符，甚至可以是表情符号！:v: :sunglasses:

## 例子群：使用 `describe` 和 `context`

例子群是按一定逻辑关系组织的例子。例子群里可以共享配置（setup）和卸载（teardown）代码。

### 使用 `describe` 描述类和方法

为了具体说明 `Dolphin` 类中 `click` 方法的行为 —— 换句话说，为了验证这个方法可用 —— 我们可以把多个 `it` 例子用 `describe` 函数组织成为一个群。把相同的例子组织在一起能更方便阅读：

```swift
// Swift

import Quick
import Nimble

class DolphinSpec: QuickSpec {
  override func spec() {
    describe("a dolphin") {
      describe("its click") {
        it("is loud") {
          let click = Dolphin().click()
          expect(click.isLoud).to(beTruthy())
        }

        it("has a high frequency") {
          let click = Dolphin().click()
          expect(click.hasHighFrequency).to(beTruthy())
        }
      }
    }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickSpecBegin(DolphinSpec)

describe(@"a dolphin", ^{
  describe(@"its click", ^{
    it(@"is loud", ^{
      Click *click = [[Dolphin new] click];
      expect(@(click.isLoud)).to(beTruthy());
    });

    it(@"has a high frequency", ^{
      Click *click = [[Dolphin new] click];
      expect(@(click.hasHighFrequency)).to(beTruthy());
    });
  });
});

QuickSpecEnd
```

当这两个例子在 Xcode 中运行的时候，它们会从 `describe` 和 `it` 函数中输出一些描述性的语言：

1. `DolphinSpec.a_dolphin_its_click_is_loud`
2. `DolphinSpec.a_dolphin_its_click_has_a_high_frequency`

显然，这两个测试各自测试的内容都很清晰明了。

### 使用 `beforeEach` 和 `afterEach` 共享配置／卸载代码

例子群不仅使它包含的例子更清晰易懂，还有助于在群里共享配置和卸载的代码。

在下面的这个示例里，例子群中的每一个例子前面，都用 `beforeEach` 这个函数创建一种新类型的海豚以及它特定的叫声。
这就保证了对每个例子进行了初始化：

```swift
// Swift

import Quick
import Nimble

class DolphinSpec: QuickSpec {
  override func spec() {
    describe("a dolphin") {
      var dolphin: Dolphin!
      beforeEach {
        dolphin = Dolphin()
      }

      describe("its click") {
        var click: Click!
        beforeEach {
          click = dolphin.click()
        }

        it("is loud") {
          expect(click.isLoud).to(beTruthy())
        }

        it("has a high frequency") {
          expect(click.hasHighFrequency).to(beTruthy())
        }
      }
    }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickSpecBegin(DolphinSpec)

describe(@"a dolphin", ^{
  __block Dolphin *dolphin = nil;
  beforeEach(^{
      dolphin = [Dolphin new];
  });

  describe(@"its click", ^{
    __block Click *click = nil;
    beforeEach(^{
      click = [dolphin click];
    });

    it(@"is loud", ^{
      expect(@(click.isLoud)).to(beTruthy());
    });

    it(@"has a high frequency", ^{
      expect(@(click.hasHighFrequency)).to(beTruthy());
    });
  });
});

QuickSpecEnd
```

对于海豚这个例子来说，像这样共享配置代码并不是一个很大的工程。但是对于更复杂的对象，共享代码能够省去大量写代码的时间！

如果想在每个例子后面执行特定的代码，可以使用 `afterEach`。

### 使用 `context` 指定条件的行为

海豚使用叫声进行回声定位。当接近了它们感兴趣的东西时，海豚会发出一系列的超声波对其进行更准确的探测。

这个测试需要展示在不同环境下，`click` 方法的不同行为。通常，海豚只叫（click）一声。但是当海豚接近它们感兴趣的东西时，它会发出很多次叫声。

这种情况可以用 `context` 函数来表示：一个 `context` 代表正常情况，另一个 `context` 代表海豚接近感兴趣的东西：

```swift
// Swift

import Quick
import Nimble

class DolphinSpec: QuickSpec {
  override func spec() {
    describe("a dolphin") {
      var dolphin: Dolphin!
      beforeEach { dolphin = Dolphin() }

      describe("its click") {
        context("when the dolphin is not near anything interesting") {
          it("is only emitted once") {
            expect(dolphin.click().count).to(equal(1))
          }
        }

        context("when the dolphin is near something interesting") {
          beforeEach {
            let ship = SunkenShip()
            Jamaica.dolphinCove.add(ship)
            Jamaica.dolphinCove.add(dolphin)
          }

          it("is emitted three times") {
            expect(dolphin.click().count).to(equal(3))
          }
        }
      }
    }
  }
}
```

```objc
// Objective-C

@import Quick;
@import Nimble;

QuickSpecBegin(DolphinSpec)

describe(@"a dolphin", ^{
  __block Dolphin *dolphin = nil;
  beforeEach(^{ dolphin = [Dolphin new]; });

  describe(@"its click", ^{
    context(@"when the dolphin is not near anything interesting", ^{
      it(@"is only emitted once", ^{
        expect(@([[dolphin click] count])).to(equal(@1));
      });
    });

    context(@"when the dolphin is near something interesting", ^{
      beforeEach(^{
        [[Jamaica dolphinCove] add:[SunkenShip new]];
        [[Jamaica dolphinCove] add:dolphin];
      });

      it(@"is emitted three times", ^{
        expect(@([[dolphin click] count])).to(equal(@3));
      });
    });
  });
});

QuickSpecEnd
```

严格地说，`context` 是 `describe` 的一种同义的表达，但是像这样有目的地使用能够让你的代码更容易理解。

### 测试的可读性：Quick 和 XCTest

在*[编写高效的 XCTest 测试: Arrange，Act 和 Assert](ArrangeActAssert.md)*里，我们知道了对每种情况进行一个测试能够很方便地组织测试代码。
在 XCTest 里，这样做会导致出现冗长的测试方法名称：

```swift
func testDolphin_click_whenTheDolphinIsNearSomethingInteresting_isEmittedThreeTimes() {
  // ...
}
```

使用 Quick ，每种情况会更容易阅读，并且我们能够为每一个例子群进行配置：

```swift
describe("a dolphin") {
  describe("its click") {
    context("when the dolphin is near something interesting") {
      it("is emitted three times") {
        // ...
      }
    }
  }
}
```

## 临时禁用例子或例子群

你可以临时禁用那些测试不通过的例子和例子群。
这些例子的名称会随着测试结果一起打印在控制台里，但它们并不运行。

通过添加前缀 `x` 就能禁用例子或例子群：

```swift
// Swift

xdescribe("its click") {
  // ...none of the code in this closure will be run.
}

xcontext("when the dolphin is not near anything interesting") {
  // ...none of the code in this closure will be run.
}

xit("is only emitted once") {
  // ...none of the code in this closure will be run.
}
```

```objc
// Objective-C

xdescribe(@"its click", ^{
  // ...none of the code in this closure will be run.
});

xcontext(@"when the dolphin is not near anything interesting", ^{
  // ...none of the code in this closure will be run.
});

xit(@"is only emitted once", ^{
  // ...none of the code in this closure will be run.
});
```

## 临时运行一部分例子

在某些情况下，只关注一个或几个例子有助于测试。毕竟只运行一两个例子比运行整个测试快多了。通过使用 `fit` 函数，你可以只运行一两个例子。你还可以使用 `fdescribe` 或 `fcontext` 把测试重点放在一个例子群：

```swift
fit("is loud") {
  // ...only this focused example will be run.
}

it("has a high frequency") {
  // ...this example is not focused, and will not be run.
}

fcontext("when the dolphin is near something interesting") {
  // ...examples in this group are also focused, so they'll be run.
}
```

```objc
fit(@"is loud", {
  // ...only this focused example will be run.
});

it(@"has a high frequency", ^{
  // ...this example is not focused, and will not be run.
});

fcontext(@"when the dolphin is near something interesting", ^{
  // ...examples in this group are also focused, so they'll be run.
});
```

## 使用 `beforeSuite` 和 `afterSuite` 进行全局配置／卸载

有一些测试的配置需要在所有例子运行之前进行。对于这种情况，可以使用 `beforeSuite` 和 `afterSuite` 。

下面的示例展示了在所有其他例子运行之前，创建一个包含了海洋中所有生物的数据库。当所有例子运行结束的时候，这个数据库就被卸载：

```swift
// Swift

import Quick

class DolphinSpec: QuickSpec {
  override func spec() {
    beforeSuite {
      OceanDatabase.createDatabase(name: "test.db")
      OceanDatabase.connectToDatabase(name: "test.db")
    }

    afterSuite {
      OceanDatabase.teardownDatabase(name: "test.db")
    }

    describe("a dolphin") {
      // ...
    }
  }
}
```

```objc
// Objective-C

@import Quick;

QuickSpecBegin(DolphinSpec)

beforeSuite(^{
  [OceanDatabase createDatabase:@"test.db"];
  [OceanDatabase connectToDatabase:@"test.db"];
});

afterSuite(^{
  [OceanDatabase teardownDatabase:@"test.db"];
});

describe(@"a dolphin", ^{
  // ...
});

QuickSpecEnd
```

你可以添加多个 `beforeSuite` 和 `afterSuite` 。所有的 
`beforeSuite` 闭包都会在其它测试运行前执行，同样，所有的 
`afterSuite` 闭包都会在其它测试运行结束后执行。
但是这些闭包并不一定按先后顺序执行。

## 访问当前例子的元数据

在某些情况下，你会想知道当前运行的例子的名称，或者目前已经运行了多少例子。Quick 提供了闭包 `beforeEach` 和 `afterEach` ，通过这些闭包，可以访问元数据。

```swift
beforeEach { exampleMetadata in
  println("Example number \(exampleMetadata.exampleIndex) is about to be run.")
}

afterEach { exampleMetadata in
  println("Example number \(exampleMetadata.exampleIndex) has run.")
}
```

```objc
beforeEachWithMetadata(^(ExampleMetadata *exampleMetadata){
  NSLog(@"Example number %l is about to be run.", (long)exampleMetadata.exampleIndex);
});

afterEachWithMetadata(^(ExampleMetadata *exampleMetadata){
  NSLog(@"Example number %l has run.", (long)exampleMetadata.exampleIndex);
});
```


