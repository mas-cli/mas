# Effective Tests Using XCTest: Arrange, Act, and Assert

XCTest や Quick に限らず、テストフレームワークを使用する際、このパターンに従うことで効率的なユニットテストを書くことができます。

1. Arrange(環境構築)
2. Act(実行)
3. Assert(動作確認)

## パターンに従ってテストを書く

例として Banana クラスを用意します。

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

ここでは `Banana.peel()` のテストをしてみましょう。このメソッドの期待する振る舞いはこのようになります。

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

## 簡潔なテスト名を用いる

この `testPeel()` テストのおかげで `Banana.peel()` が正しく動作しない場合、すぐ気付くことができます。
我々のアプリケーションコードを変更することで正しく動作しないケース(テストが失敗するケース)はしばしば起こります。
テストが失敗する場合は下記どちらかのケースになります。

1. 間違えてアプリケーションコードを壊してしまっているため、直す必要がある
2. アプリケーションコードは期待したとおりに動いているが、もともと期待した機能が変わっているためテストコードを直す必要がある

もしテストが失敗した場合、どちらのケースに当てはまる判断する必要が出てきます。そのためテスト名が分かりやすいことが重要になります。

良いテスト名とは、

1. 何をテストしているか明確であること
2. どのような時にテストがパスするか・失敗するか明確であること

例に挙げた `testPeel()` は良いテスト名でしょうか？分かりやすくしてみましょう。

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

新しいテスト名は、

1. 何をテストしているか明確である: `testPeel` は `Banana.peel()` メソッドをテストしてることを示す。
2. どのような時にテストがパスするか明確である: `makesTheBananaEdible` はバナナが食べられるか(edible)どうかをテストしていることを示す。

## テスト時の条件

人々がバナナを欲しい時、`offer()` というメソッドを使います。

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

私達のアプリケーションコードは２つのうちどちらかを実行します：

1. 食べられる(すでに皮がむかれている)バナナを注文するか
2. まだ食べられない(すでに皮がむかれている)バナナを注文するか

両方のケースをテストしてみましょう。

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

私達のテスト名は'どのような条件でテストをパスするか'を明確に表しています。
`whenTheBananaIsPeeled`, `offer()` のケースでは `offersTheBanana` となるべきです。またバナナの皮がむかれていない場合は？
ここでは両方共テストしています。

ここで大事なことはアプリケーションコード内の各`if`文に対してそれぞれ１つのテストを持っていることです。
これはテストを書く際の重要なアプローチです。このアプローチでは全ての条件(if文)に関してテストされていることを保証します。
テストのうちどれか１つがでも失敗するようになったらコードの見直しをする必要があります。テスト名が分かりやすいとすぐにチェックすべき箇所が分かります。

## `XCTestCase.setUp()`を用いて簡潔に環境構築をする

`OfferTests` の２つのテストのどちらにも同じ"環境構築"のコードが入っています。
どちらのテストでも banana を作っています。このコードは一箇所にまとめるべきです。なぜでしょう？

1. そのままにしておく場合、もし `Banana` の生成方法が変わったら, 私たちは全てのテストを修正しないといけなくなります。
2. テストコードが短くなり、テストの可読性が向上します。

Banana の生成方法を `XCTestCase.setUp()` の中に移しましょう。`XCTestCase.setUp()` は各テストの実行前に一度呼び出されます。

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

## 複数のテストにまたがって環境構築を共有する

もし複数のテストにまたがって同じ環境構築のコードを使っている部分があれば、 test target 内に'ヘルパー関数'を定義しましょう。

```swift
// BananaTests/BananaHelpers.swift

internal func createNewPeeledBanana() -> Banana {
  let banana = Banana()
  banana.peel()
  return banana
}
```

> 共通操作を定義するのに関数を使いましょう。関数は継承できず、状態を保持することができません。継承や状態を持たせる場合、テストの可読性が落ちてしまいます。
