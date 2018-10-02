# Effective Tests Using XCTest: Arrange, Act, and Assert

Whether you're using XCTest, Quick, or another testing framework, you can write
effective unit tests by following a simple pattern:

1. Arrange
2. Act
3. Assert

## Using Arrange, Act, and Assert

For example, let's look at a simple class called `Banana`:

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

Let's verify the `Banana.peel()` method does what it's supposed to:

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

## Using Clear Test Names

Our `testPeel()` makes sure that, if the `Banana.peel()` method ever
stops working right, we'll know. This usually happens when our application
code changes, which either means:

1. We accidentally broke our application code, so we have to fix the application code
2. We changed how our application code works--maybe because we're adding a new
   feature--so we have to change the test code

If our tests start breaking, how do we know which one of these cases applies? It might
surprise you that **the name of the test** is our best indication. Good test names:

1. Are clear about what is being tested.
2. Are clear about when the test should pass or fail.

Is our `testPeel()` method clearly named? Let's make it clearer:

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

The new name:

1. Is clear about what is being tested: `testPeel` indicates it's the `Banana.peel()` method.
2. Is clear about when the test should pass: `makesTheBananaEdible` indicates the
   banana is edible once the method has been called.

## Testing Conditions

Let's say we want to offer people bananas, using a function called `offer()`:

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

Our application code does one of two things:

1. Either it offers a banana that's already been peeled...
2. ...or it offers an unpeeled banana.

Let's write tests for these two cases:

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

Our test names clearly indicate the **conditions** under which our tests should pass:
in the case that `whenTheBananaIsPeeled`, `offer()` should `offersTheBanana`. And if
the banana isn't peeled? Well, we have a test for that, too!

Notice that we have one test per `if` statement in our application code.
This is a great pattern when writing tests: it makes sure every set of conditions
is tested. If one of those conditions no longer works, or needs to be changed, we'll know
exactly which test needs to be looked at.

## Shorter "Arrange" Steps with `XCTestCase.setUp()`

Both of our `OfferTests` tests contain the same "Arrange" code: they both
create a banana. We should move that code into a single place. Why?

1. As-is, if we change the `Banana` initializer, we'll have to change every test that creates a banana.
2. Our test methods will be shorter--which is a good thing if (and **only if**) that makes
   the tests easier to read.

Let's move the `Banana` initialization into the `XCTestCase.setUp()` method, which is called
once before every test method.

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

## Sharing "Arrange" Code Across Multiple Tests

If you find yourself using the same "arrange" steps across multiple tests,
you may want to define a helper function within your test target:

```swift
// BananaTests/BananaHelpers.swift

internal func createNewPeeledBanana() -> Banana {
  let banana = Banana()
  banana.peel()
  return banana
}
```

> Use a function to define your helpers: functions can't be subclassed, nor
  can they retain any state. Subclassing and mutable state can make your tests
  harder to read.
