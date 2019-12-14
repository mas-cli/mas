# Shared Assertions를 사용하여 테스트 상용구 줄이기

때에 따라, 같은 명세서가 여러 객체에 적용될 수 있습니다.

예를 들어, `Edible`이라는 프로토콜을 생각해 보자. 돌고래가 `Edible` 한 (먹을 수 있는) 음식을 먹으면 돌고래는 행복해집니다. `Mackerel`(고등어) 와
`Cod`(대구)는 모두 먹을 수 있습니다. Quick은 돌고래가 어느 쪽을 먹어도 기쁘다는 것을 쉽게 테스트할 수 있게 합니다. 

아래 예제는 "먹을 수 있는 것" 에 대한 "공유 명세"를 정의하고, 고등어와 대구가 모두 "먹을 수 있는 것"처럼 행동하도록 지정합니다:

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
    it(@"makes dolphins happy", ^{
      Dolphin *dolphin = [[Dolphin alloc] init];
      dolphin.happy = NO;
      id<Edible> edible = exampleContext()[@"edible"];
      [dolphin eat:edible];
      expect(dolphin.isHappy).to(beTruthy())
    });
  });
}

QuickConfigurationEnd

QuickSpecBegin(MackerelSpec)

__block Mackerel *mackerel = nil;
beforeEach(^{
  mackerel = [[Mackerel alloc] init];
});

itBehavesLike(@"something edible", ^{ return @{ @"edible": mackerel }; });

QuickSpecEnd

QuickSpecBegin(CodSpec)

__block Mackerel *cod = nil;
beforeEach(^{
  cod = [[Cod alloc] init];
});

itBehavesLike(@"something edible", ^{ return @{ @"edible": cod }; });

QuickSpecEnd
```

공유된 예제들은 임의 개수의 `it`, `context`, `describe` 블록이 포함될 수 있습니다. 이들은 여러 다른 객체에 대해 같은 테스트를 실행할 때 많은 타이핑을 절약할 수 있습니다.

어떤 경우에는, 추가 컨텍스트가 필요하지 않습니다. Swift에서는, 어떤 매개변수도 사용하지 않는 `sharedExamples` 클로저를 사용할 수 있습니다. 이것은 일종의 전역 상태의 어떤 테스트를 할 때 유용할 수 있습니다:

```swift
// Swift

import Quick

sharedExamples("everything under the sea") {
  // ...
}

itBehavesLike("everything under the sea")
```

> Objective-C에서는, 해당 인수를 사용할 계획이 없더라도,  `QCKDSLSharedExampleContext`를 사용하는 블록을 전달해야 합니다. 미안하지만, 이것이 쿠키를 부수는 방식이다!
>   :cookie: :bomb:

역시나 `fitBehavesLike` 함수를 이용해서 공유 예제를 "집중" 할 수 있습니다.
