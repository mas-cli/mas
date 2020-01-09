# Quick Example과 Example그룹으로 구성된 테스트

Quick에는 **examples**와 **example groups**를 정의하기 위한 특별한 문법이 있습니다.

*[XCTest를 사용한 효과적인 테스트 : Arrange, Act, 그리고 Assert](ArrangeActAssert.md)* 에서,
좋은 테스트 메소드 이름을 붙이는 것이 매우 중요하다는 것을 배웠습니다. — 테스트가 실패했을 때, 테스트 이름은 응용 프로그램 코드를 수정할지, 테스트 코드를 업데이트할지를 결정하는 데 중요한 자료가 됩니다.

Quick examples과 example그룹은 두 가지 용도로 사용됩니다:

1. 서술적인 테스트 이름을 작성하는 것을 장려합니다.
2. 테스트 "환경 구축" 단계에서 코드를 매우 단순하게 합니다.

## `it`을 사용한 Examples

 `it` 함수로 정의된 Examples는, 코드가 어떻게 동작하는지를 보여주기 위해 assertions를 사용합니다. 이것들은 XCTest의 테스트 메소드와 같습니다.

`it`은 example의 이름과 클로저, 두 개의 파라미터가 필요합니다.
아래 example은 `Sea.Dolphin` 클래스가 어떻게 동작하는지를 지정합니다. 
새로운 돌고래는 영리하고 친절해야 합니다:

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

설명을 사용해서 example이 테스트 중인 내용을 명확하게 하세요.
설명은 어떠한 길이의 아무 문자가 가능하며, 영어 이외로 된 언어나 심지어 이모지를 포함한 모든 문자를 사용할 수 있습니다! :v: :sunglasses:

## `describe`과 `context`를 사용한 Example그룹 

Example 그룹은 example의 논리적 그룹입니다. Example 그룹은 설정(setup)과 분해(teardown) 코드를 공유할 수 있습니다.

### 서술하는 클래스와 `describe`를 사용하는 메소드

`Dolphin` 클래스의 `click` 메소드의 동작을 지정하기 위해서는 (다시 말해, 메소드의 동작을 테스트하기 위해서는) 몇 가지 `it` example을 `describe` 함수를 이용해서 그룹화시킬 수 있습니다. 비슷한 example을 그룹화하면 spec을 더 쉽게 읽을 수 있습니다:

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

이 두 가지 example이 Xcode에서 실행되면, `describe` 과 `it` 함수들의 설명이 표시될 겁니다:

1. `DolphinSpec.a_dolphin_its_click_is_loud`
2. `DolphinSpec.a_dolphin_its_click_has_a_high_frequency`

다시 말해, 각각의 example이 테스트하고 있는 것이 명확합니다.

### `beforeEach` 와 `afterEach`를 사용하여 설정 / 해제코드 공유하기

Example groups는 example을 더 명확하게 만들어줄 뿐만 아니라, example 그룹 간에 설정 및 해제 코드를 공유하는 데 유용합니다.

아래 example에서, `beforeEach` 함수는 그룹에서 각 example 앞에 돌고래와 클릭의 새로운 인스턴스를 생성하는 데 사용되었습니다.
이렇게 하면 모든 example에서 각각은 "신선한" 상태가 되었습니다:

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

이러한 공유 설정이 돌고래 예제에서와 큰 차이가 없는 것처럼 보일 수 있지만, 더 복잡한 객체라면 많은 타이핑을 줄여 줄 것입니다!

각각의 example *다음에* 코드를 실행하려면 `afterEach`를 사용하세요.

### `context`를 사용하여 조건부 동작 지정하기

돌고래는 반항위치 결정법(박쥐 등이 초음파를 발사하여 위치를 알아내는 일)을 위해 클릭을 사용합니다. 그들이 특히 흥미로운 것에 접근하면, 그것이 무엇인지 알기 위해 일련의 클릭을 하게 됩니다.

테스트는 `click` 메소드가 다른 상황에서 다르게 동작하는 것을 보여줄 필요가 있습니다. 일반적으로, 돌고래는 한 번만 클릭합니다. 하지만 돌고래가 어떤 흥미로운 것에 접근하게 된다면, 여러 번 클릭할 것입니다.

이것은 `context` 함수를 이용해서 표현할 수 있습니다: 일반적인 `context`와, 돌고래가 흥미로운 것에 가까이 갔을 때의 `context`입니다:

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

엄밀히 얘기하면, `context` 키워드는 `describe`과 동의어지만, 사려 깊은 사용은 spec을 더 이해하기 쉽게 만들 것입니다.

### 테스트 가독성: Quick과 XCTest

[Effective Tests Using XCTest: Arrange, Act, and Assert](ArrangeActAssert.md)에서,
우리는 테스트 당 하나의 조건이 테스트 코드를 구성하는 좋은 방법이라 알아봤습니다.
XCTest에서는, 긴 테스트 메소드 이름을 사용합니다:

```swift
func testDolphin_click_whenTheDolphinIsNearSomethingInteresting_isEmittedThreeTimes() {
  // ...
}
```

Quick을 사용하면, 조건을 더 쉽게 읽을 수 있고, 각 example 그룹에 대해 설정을 할 수 있습니다:

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

## 일시적으로 Example이나 그룹을 비활성화하기

일시적으로 통과하지 못한 example이나 example 그룹을 비활성화 시킬 수 있습니다.
Example의 이름은 테스트 결과와 함께 출력되지만, 비활성화된 것들은 출력되지 않을 것입니다.

example이나 group에 `x`를 추가함으로써 비활성화 시킬 수 있습니다:

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

## 포커스 된 Example의 일정 부분을 임시적 실행하기

때로는 오직 하나나 몇 가지 Example 에만 집중하는 것이 도움이 됩니다. 하나 또는 두 가지의  example만 실행하는 것은 전체를 실행하는 것보다 빠릅니다. `fit` 함수를 사용해서 하나 또는 두 개만 실행할 수 있습니다. `fdescribe` 이나 `fcontext`를 사용해서 역시 Example 그룹에 집중할 수 있습니다:

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

##  `beforeSuite` 와 `afterSuite`를 사용하여 전역 설정 / 해제하기

어떤 테스트 설정은 실행되기 전에 일부 example이 실행되어야 합니다. 이럴 때, `beforeSuite `와 `afterSuite`를 사용합니다.

아래의 예제에서는, 모든 example이 실행되기 전에 바다의 모든 생물 데이터베이스가 생성됩니다. 모든 example이 완료되면 데이터베이스는 제거됩니다.

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

`beforeSuite`와 `afterSuite`를 원하는 만큼 지정할 수 있습니다. 모든
`beforeSuite` 클로저는 테스트가 실행되기 전에 실행되고, 모든 
`afterSuite` 클로저는 모든 테스트가 끝난 뒤에 실행될 것입니다.
이 클로저들이 어떤 순서로 실행될지는 보장되지 않습니다.

## 현재 Example의 메타데이터에 액세스하기

현재 실행되고 있는 example에 대한 이름이나, 지금까지 실행되었던 example의 이름을 알고 싶어하는 경우가 있을 수 있습니다. Quick은 `beforeEach`와 `afterEach` 클로저에서 메타데이터에 대한 액세스를 제공합니다.

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
