# Reducing Test Boilerplate with Shared Assertions

In some cases, the same set of specifications apply to multiple objects.

For example, consider a protocol called `Edible`. When a dolphin
eats something `Edible`, the dolphin becomes happy. `Mackerel` and
`Cod` are both edible. Quick allows you to easily test that a dolphin is
happy to eat either one.

The example below defines a set of  "shared examples" for "something edible",
and specifies that both mackerel and cod behave like "something edible":

```swift
// Swift

import Quick
import Nimble

class EdibleSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("something edible") { (sharedExampleContext: @escaping SharedExampleContext) in
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

Shared examples can include any number of `it`, `context`, and
`describe` blocks. They save a *lot* of typing when running
the same tests against several different kinds of objects.

In some cases, you won't need any additional context. In Swift, you can
simply use `sharedExamples` closures that take no parameters. This
might be useful when testing some sort of global state:

```swift
// Swift

import Quick

sharedExamples("everything under the sea") {
  // ...
}

itBehavesLike("everything under the sea")
```

> In Objective-C, you'll have to pass a block that takes a
  `QCKDSLSharedExampleContext`, even if you don't plan on using that
  argument. Sorry, but that's the way the cookie crumbles!
  :cookie: :bomb:

You can also "focus" shared examples using the `fitBehavesLike` function.
