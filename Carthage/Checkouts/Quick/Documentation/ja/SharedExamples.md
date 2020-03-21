# assertの共有でボイラープレートコードをなくしましょう

複数のオブジェクトに対象して同じ内容のテストを行いたい場合があります。

例えば `Edible` という protocol があるとします。
イルカ(dolphin)が何か食べられる(`Edible`な)ものを食べるとイルカが幸せになります。
サバ(`Mackerel`)とタラ(`Cod`)は食べられる(`Edible`な)ものです。

Quick は「イルカがどちらかを食べて幸せになる」ということを簡単にテストすることできます。

下記で示すテストは "(何かを食べる)something edible" という共有できるテスト(Shared examples)を定義しています。
また、この共有できるテストでサバ(Mackerel)とタラ(Cod)を食べることについてのテストを記述しています。

```swift
// Swift

import Quick
import Nimble

class EdibleSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
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

Shared examples は `it`, `context` や `describe` のブロックをいくつでも含めることができます。
これは異なる種類の対象についてテストをする際のコードを節約することができます。

あるケースでは context を追加する必要もありません。
Swift では `sharedExamples` closure を使って共有できるテストを定義することができます。
このテクニックはある時点での状態をテストしたい時などに役に立つかもしれません。

```swift
// Swift

import Quick

sharedExamples("everything under the sea") {
  // ...
}

itBehavesLike("everything under the sea")
```

> Objective-Cでは, `QCKDSLSharedExampleContext` を引数に取る block を渡すことができます。※QCKDSLSharedExampleContext を使う予定がなくても引数に取る block を用意してください。めんどくさくても。世の中そんなもんです。  :cookie: :bomb:

`itBehavesLike` の先頭に `f` を加えて(`fitBehavesLike`) として共有できるテストのみ実行することもできます。
