# 编写高效的 XCTest 测试: Arrange，Act 和 Assert

当你使用 XCTest，Quick 或者其他测试框架时，你可以遵循下面的模式来编写有效的单元测试：

1. Arrange － 安排好所有先要条件和输入
2. Act － 对要测试的对象或方法进行演绎   
3. Assert － 作出预测结果的断言

## Arrange, Act, and Assert 三部曲

举个例子，假设现在有一个叫 `Banana` 的类：

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

现在我们想验证一下 `Banana.peel()` 方法的行为是否跟我们设想的一样：

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

## 使用明确清晰的方法名字

我们的 `testPeel()` 函数可以确保如果 `Banana.peel()` 方法出了问题，我们可以第一时间知道。这通常发生在我们修改了应用的代码后，同时也意味着：

1. 如果我们意外地写错了代码，我们需要修复它从而让代码正常工作。
2. 或者我们可能为了增加一个新的功能而改变原有的代码 —— 因此我们需要更改现有的测试代码。

如果我们的测试开始出现失败，怎么才能知道是哪一个测试用例失败呢？这可能会让你吃惊，最好的办法是从 **测试方法的名字** 找出端倪。好的测试方法会：

1. 明确什么是对正在被测试的对象。
2. 明确什么时候测试应该通过，什么时候测试应该失败。

那我们上面的 `testPeel()` 方法的命名清晰吗？我们可以让它变得更清晰：

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

新的方法命名：

1. 明确了什么是正在被测试的对象：`testPeel` 指明了正在被测试的是 `Banana.peel()` 方法。
2. 明确了测试通过的条件：`makesTheBananaEdible` 指明了只要这个测试方法被调用后，香蕉就已经被剥皮（可食用）。

## 对条件进行测试

假设我们现在可以向别人提供香蕉，有这样一个叫 `offer()` 的函数：

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

我们的代码做了以下其中一件事：

1. 给别人一个已经被剥过皮的香蕉。
2. 或者给别人一个没剥皮的香蕉。

现在让我们为这两种情况编写测试：

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

我们的方法名字清晰地指明了测试通过时所应具备的**条件**：在 `whenTheBananaIsPeeled` 测试中，`offer()` 方法应该 `offersTheBanana`。那香蕉没被剥皮的情况呢？好吧，我们也写了另外一个测试来测试这种情况。

注意，我们为每个 `if` 条件单独写了一个测试。在我们写测试时，确保每个条件都能被测试，是一个好的模式。如果其中一个条件不再满足，或者需要修改，我们就很容易知道哪个测试需要处理。

## 用 `XCTestCase.setUp()` 来编写更简洁的 "Arrange"

我们的两个 `OfferTests` 测试都包含了相同的 "Arrange" 代码：他们都初始化了一个香蕉。我们应该把初始化方法移到一个单独的地方。为什么？

1. 现在，假设需要修改 `Banana` 的初始化方法，那么我们就要对每个方法进行修改。
2. 我们的测试方法会更加简洁 —— 这对于我们是一件好事，当且**仅当**测试方法能更容易被人阅读的时候。

现在我们把 `Banana` 的初始化方法移到 `XCTestCase.setUp()` 方法里，这样当每个测试开始时，初始化方法都会被调用。

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

## 在不同的测试里共享 "Arrange" 代码

如果你发现你在很多地方都有相同重复的 "arrange" 方法，你可能想定义一个通用的 helper 函数：

```swift
// BananaTests/BananaHelpers.swift

internal func createNewPeeledBanana() -> Banana {
  let banana = Banana()
  banana.peel()
  return banana
}
```

> 用一个通用函数来定义那些不能被抽象，或不会保存状态的方法。抽象的子类和可修改的状态会使你的测试难以阅读。


