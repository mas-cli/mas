# QuickのExamplesとExample Groupsで、たくさんのテストでも整理整頓

Quick では **examples** と **example groups** という特別な文法があります。

*[XCTestで役に立つテストを書く方法：Arrange（環境構築）, Act（実行）, and Assert（動作確認）](ArrangeActAssert.md)* では,
良いテスト名をつけることがとても重要だということを学びました。
テストが失敗した時、テスト名はアプリケーションコードを直すべきかテストを修正すべきかを判断する際の重要な材料になります。

Quick の examples(テスト) と example groups(テストグループ) は二つの役に立ちます。

1. 記述的なテスト名を書くためことをサポートします
2. テスト中の "環境構築" 部分におけるコードを簡略化します

## Examples の `it`

Examples は `it` という「コードがどのように動作すべきかを宣言する」関数を持ちます。
これは XCTest の test methods のようなものです。

`it` 関数は２つのパラメータ、example の名前と closure です。
下記のテストでは `Sea.Dolphin` クラスがどのように動作すべきかを記述しています。
この example では「新しく生成された Dolphin は　smart で friendly であるべき」と書いています。

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

Examples が何をテストしているかを明確にするために Description を使います。
Description は文字数制限がなくどの文字でも(絵文字さえも！)使うことができます。
:v: :sunglasses:

## Example Groups の `describe` と `context`

Example groups では Example のグルーピングができ、 setup と teardown のコードを共有できます。

### `describe` を使ってクラスと関数について記述する

`Dolphin` クラスの `click` 関数の動作を記述する際に、
言い換えると関数が動作していることをテストする際に、
複数の `it` example を `describe` を用いてグルーピングすることができます。
似ている examples をまとめることで可読性が向上します。

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

Xcode でこれらの examples を実行すると`describe` と `it` の記述内容も表示されます。上記のテストの場合、下記のような出力になります。

1. `DolphinSpec.a_dolphin_its_click_is_loud`
2. `DolphinSpec.a_dolphin_its_click_has_a_high_frequency`

それぞれの Example が何をテストしているかが明確ですね。

### `beforeEach` と `afterEach` を使って Setup/Teardown のコードを共有する

Example groups はテストの内容をただ分かりやすくするだけでなく同一グループ内のsetup/teardownコードを共有することができます。

下記の例では`its click`の Example group のテストを実行する前に `beforeEach`を使って新しい Dolphin のインスタンスを生成しています。
各 Example において "新しい" 状態でテストが行えます。 

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

この例では setup を共有することはあまりメリットがないように見えるかもしれませんが
複数の複雑なオブジェクトを生成する時などコード量を節約することができます。

それぞれの Example を実行した後に実行したいコードについては`afterEach`を使います。

### `context` を使ってある条件での動作を記述する

例の Dolphins(イルカ達) はエコーロケーションのために カチッと音を立てます(`click` 関数を呼び出します)。
イルカ達は特に興味のあるものに近づく時、それが何かを調べるために連続してエコーロケーション(`click` 関数を呼び出します)を行います。

このシナリオにおいてテストが 異なる状況において `click` 関数の動作は異なる ということを表す必要があります。

基本的にイルカは一度音を鳴らすだけですが、イルカ達が興味があるものが近くにあると連続して音を鳴らします。

この状況について `context` 関数を使って表します。ある `context` では通常のケースで、もう一方の`context`ではイルカが興味あるものに近づいているケースです。

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

厳密には `context` キーワードは `describe`と同じですがテストを理解しやすくなるので使い分けるとよいです。

### テストの可読性: Quick と XCTest

*[XCTestで役に立つテストを書く方法：Arrange（環境構築）, Act（実行）, and Assert（動作確認）](ArrangeActAssert.md)*で各条件についてそれぞれテストを用意するのがテストを書く際の重要な方法と述べましたが
このアプローチで XCTest でテストを書くとテスト名が長くなってしまいます。

```swift
func testDolphin_click_whenTheDolphinIsNearSomethingInteresting_isEmittedThreeTimes() {
  // ...
}
```

Quick を使うと条件について読みやすく、しかもそれぞれの Example group について環境構築が効率的に行えます。

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

## 一時的に Examples や Example Groups を無効にする

通っていない Example を一時的に無効にすることもできます。
Example や Example Groups の先頭に `x` をつけると無効になります。
Examples の名前がテスト結果の中に出力されますがテストは実行されなくなります。


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

## 指定した Examples だけ一時的に実行する

一部の Example だけ実行できると便利なこともあります。
そのような時は実行したい Example を `fit` 関数を用いて指定します。
特定の Example group だけ実行したい時は`fdescribe` か `fcontext` を記述します。
※もともと書いてあるテストコードの先頭に `f` を追記するだけです。

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

## `beforeSuite` と `afterSuite` を使ってテスト全体に対する Setup/Teardown を行う

テストの環境構築の中にはどの Example よりも先に、または最後に実行したいものがある場合もあります。
このような時は `beforeSuite` か `afterSuite` を使います。

下記の例では 全ての Example が実行される前に一度だけ海の全ての生物のデータベースが生成され、全ての Exmample が実行された後にデータベースを削除しています。

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

`beforeSuite` and `afterSuite` は必要な数だけ定義することができます。
全ての `beforeSuite` の closure は全てのテストが実行される前に実行され、
全ての `afterSuite` の closure は全てのテストが実行された後に実行されます。

複数の `beforeSuite`(`afterSuite`) の closure を記述した場合、これらの実行順序は記述した順序で実行されるかは保証されません。

## 実行中の Example でメタデータにアクセスする

実行中の Example の中で、Example名を知りたいケース、これまでに何件の Example を実行したかを知りたいケースがあるかもしれません。 
Quick ではこれらの情報に `beforeEach` と `afterEach` の closure の中からアクセスすることができます。

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
