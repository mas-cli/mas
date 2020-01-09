# XCTest를 사용한 효과적인 테스트 : Arrange, Act, 그리고 Assert

XCTest, Quick, 또는 다른 테스트 프레임워크를 사용하는 경우, 간단한 패턴을 따라 효과적인 단위 테스트를 작성할 수 있습니다:

1. Arrange (환경 구축)
2. Act (실행)
3. Assert (동작 확인)

## Arrange, Act, and Assert 사용하기

예를 들어, `Banana`라는 클래스를 간단히 살펴봅시다:

```swift
// Banana/Banana.swift

/** A delicious banana. Tastes better if you peel it first. */
public class Banana {
  private var isPeeled = false

  /** Peels the banana. */
  public func peel() {
    isPeeled = true
  }

  /** You shouldn't eat a banana unless it's been peeled. */
  public var isEdible: Bool {
    return isPeeled
  }
}
```

 `Banana.peel()`  메서드가 어떻게 되는지 확인해 봅시다:

```swift
// BananaTests/BananaTests.swift

class BananaTests: XCTestCase {
  func testPeel() {
    // Arrange: Create the banana we'll be peeling.
    let banana = Banana()

    // Act: Peel the banana.
    banana.peel()

    // Assert: Verify that the banana is now edible.
    XCTAssertTrue(banana.isEdible)
  }
}
```

## 간단한 테스트 이름 사용하기

이 `testPeel()` 테스트 덕분에 `Banana.peel()` 메소드가 제대로 작동하지 않는다면 즉시 알 수 있습니다. 이는 일반적으로 응용 프로그램 코드가 변경되면서 발생합니다.

1. 우리는 뜻하지 않게 응용 프로그램 코드를 망가트리므로, 응용 프로그램 코드를 수정해야 합니다.
2. 우리는 응용 프로그램의 작동 방식을 변경했습니다. — 아마도 새로운 기능을 추가했기 때문일 수 있습니다. — 그래서 우리는 테스트 코드를 변경해야 합니다. 

만약 테스트가 실패하기 시작한다면, 위 두 가지 중 어떤 케이스인지 어떻게 알 수 있을까요? 따라서 **테스트의 이름**을 알기 쉬운 것이 중요하다는 사실을 알려줍니다. 좋은 테스트 이름들 :

1. 무엇을 테스트하고 있는지 명확합니다.
2. 어떤 때 테스트가 통과하거나 실패하는지 명확합니다.

 `testPeel()` 메소드는 좋은 테스트 이름일까요? 더 명확하게 바꾸어 봅시다:

```diff
// BananaTests.swift

-func testPeel() {
+func testPeel_makesTheBananaEdible() {
  // Arrange: Create the banana we'll be peeling.
  let banana = Banana()

  // Act: Peel the banana.
  banana.peel()

  // Assert: Verify that the banana is now edible.
  XCTAssertTrue(banana.isEdible)
}
```

새로운 이름:

1. 무엇을 테스트하고 있는지 명확합니다 : `testPeel` 은  `Banana.peel()` 메소드 임을 나타냅니다.
2. 어떤 때 테스트가 통과하거나 실패하는지 명확합니다 : `makesTheBananaEdible` 는 메소드가 호출되면 바나나가 식용 가능한 상태임을 나타냅니다.

## 테스트 시 조건들

`offer()` 함수를 사용해서 사람들에게 바나나를 제공하고 싶다고 가정해 보겠습니다 :

```swift
// Banana/Offer.swift

/** Given a banana, returns a string that can be used to offer someone the banana. */
public func offer(banana: Banana) -> String {
  if banana.isEdible {
    return "Hey, want a banana?"
  } else {
    return "Hey, want me to peel this banana for you?"
  }
}
```

우리의 프로그램 코드는 다음 두 가지 중 하나를 수행합니다 :

1. 이미 벗겨진(먹을 수 있는) 바나나를 제공합니다…
2. …또는 벗겨지지 않은(먹을 수 없는) 바나나를 제공합니다.

이 두 가지 경우에 대한 테스트를 작성해 봅시다 :

```swift
// BananaTests/OfferTests.swift

class OfferTests: XCTestCase {
  func testOffer_whenTheBananaIsPeeled_offersTheBanana() {
    // Arrange: Create a banana and peel it.
    let banana = Banana()
    banana.peel()

    // Act: Create the string used to offer the banana.
    let message = offer(banana)

    // Assert: Verify it's the right string.
    XCTAssertEqual(message, "Hey, want a banana?")
  }

  func testOffer_whenTheBananaIsntPeeled_offersToPeelTheBanana() {
    // Arrange: Create a banana.
    let banana = Banana()

    // Act: Create the string used to offer the banana.
    let message = offer(banana)

    // Assert: Verify it's the right string.
    XCTAssertEqual(message, "Hey, want me to peel this banana for you?")
  }
}
```

테스트 이름은 테스트가 통과해야 하는 **조건**을 명확하게 나타내야 합니다 : 예를 들면 `whenTheBananaIsPeeled`, `offer()` 은 `offersTheBanana` 가 되어야 합니다. 만약 바나나가 벗겨지지 않은 경우라도 우리는 역시 이 경우를 테스트했습니다!

코드에서 `if` 문 하나에 테스트가 하나씩 가지고 있는 것을 주목해 봅시다. 이것은 테스트를 작성할 때 훌륭한 패턴입니다 : 이 패턴은 모든 조건이 테스트 되는 것을 보장합니다. 이러한 조건 중 하나가 더 이상 작동하지 않거나 변경이 필요 없게 된다면, 우리는 어떤 검사가 필요한지 정확히 알 수 있게 됩니다.

## `XCTestCase.setUp()` 을 사용하여 간단히 환경구축 하기

`OfferTests` 에는 같은 "환경 구축" 코드가 포함되어 있습니다 : 이들은 둘 다 바나나를 만듭니다. 우리는 이 코드를 한 곳에 정리해야 합니다. 왜일까요?

1. 그대로 두었을 때 `바나나` 생성 방식이 변경되면, 모든 바나나를 만드는 테스트들을 수정해야 합니다. 
2. 테스트 코드가 짧아지고 (그리고 **그렇게 만드는 경우에만** ) 테스트의 가독성이 향상됩니다.

`바나나` 초기화 코드를 모든 테스트 메소드 전에 한 번 실행되는  `XCTestCase.setUp()` 안으로 옮기세요.

```diff
// OfferTests.swift

class OfferTests: XCTestCase {
+  var banana: Banana!
+
+  override func setUp() {
+    super.setUp()
+    banana = Banana()
+  }
+
  func testOffer_whenTheBananaIsPeeled_offersTheBanana() {
-    // Arrange: Create a banana and peel it.
-    let banana = Banana()
+    // Arrange: Peel the banana.
    banana.peel()

    // Act: Create the string used to offer the banana.
    let message = offer(banana)

    // Assert: Verify it's the right string.
    XCTAssertEqual(message, "Hey, want a banana?")
  }

  func testOffer_whenTheBananaIsntPeeled_offersToPeelTheBanana() {
-    // Arrange: Create a banana.
-    let banana = Banana()
-
    // Act: Create the string used to offer the banana.
    let message = offer(banana)

    // Assert: Verify it's the right string.
    XCTAssertEqual(message, "Hey, want me to peel this banana for you?")
  }
}
```

## "환경구축" 코드를 여러 테스트에서 공유하기

여러 테스트 간에 동일한 "환경구축" 코드를 사용하는 부분을 발견하면, test target에 'helper 함수'를 정의합시다 :

```swift
// BananaTests/BananaHelpers.swift

internal func createNewPeeledBanana() -> Banana {
  let banana = Banana()
  banana.peel()
  return banana
}
```

> 함수를 사용하여 헬퍼를 정의하십시오 : 함수는 서브클래스화 할 수 없으며, 어떤 상태도 유지할 수 없습니다. 서브 클래스화 및 변경 가능한 상태는 당신의 테스트를 읽기 힘들게 합니다.
