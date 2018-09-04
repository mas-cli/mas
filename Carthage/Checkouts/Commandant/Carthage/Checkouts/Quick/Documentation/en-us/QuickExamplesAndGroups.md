# Organized Tests with Quick Examples and Example Groups

Quick uses a special syntax to define **examples** and **example groups**.

In *[Effective Tests Using XCTest: Arrange, Act, and Assert](ArrangeActAssert.md)*,
we learned that a good test method name is crucial--when a test starts failing, it's
the best way to determine whether we have to fix the application code or update the test.

Quick examples and example groups serve two purposes:

1. They encourage you to write descriptive test names.
2. They greatly simplify the test code in the "arrange" step of your tests.

## Examples Using `it`

Examples, defined with the `it` function, use assertions to demonstrate
how code should behave. These are like test methods in XCTest.

`it` takes two parameters: the name of the example, and a closure.
The examples below specify how the `Sea.Dolphin` class should behave.
A new dolphin should be smart and friendly:

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

Use descriptions to make it clear what your examples are testing.
Descriptions can be of any length and use any character, including
characters from languages besides English, or even emoji! :v: :sunglasses:

## Example Groups Using `describe` and `context`

Example groups are logical groupings of examples. Example groups can share
setup and teardown code.

### Describing Classes and Methods Using `describe`

To specify the behavior of the `Dolphin` class's `click` method--in
other words, to test the method works--several `it` examples can be
grouped together using the `describe` function. Grouping similar
examples together makes the spec easier to read:

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

When these two examples are run in Xcode, they'll display the
description from the `describe` and `it` functions:

1. `DolphinSpec.a_dolphin_its_click_is_loud`
2. `DolphinSpec.a_dolphin_its_click_has_a_high_frequency`

Again, it's clear what each of these examples is testing.

### Sharing Setup/Teardown Code Using `beforeEach` and `afterEach`

Example groups don't just make the examples clearer, they're also useful
for sharing setup and teardown code among examples in a group.

In the example below, the `beforeEach` function is used to create a brand
new instance of a dolphin and its click before each example in the group.
This ensures that both are in a "fresh" state for every example:

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

Sharing setup like this might not seem like a big deal with the
dolphin example, but for more complicated objects, it saves a lot
of typing!

To execute code *after* each example, use `afterEach`.

### Specifying Conditional Behavior Using `context`

Dolphins use clicks for echolocation. When they approach something
particularly interesting to them, they release a series of clicks in
order to get a better idea of what it is.

The tests need to show that the `click` method behaves differently in
different circumstances. Normally, the dolphin just clicks once. But when
the dolphin is close to something interesting, it clicks several times.

This can be expressed using `context` functions: one `context` for the
normal case, and one `context` for when the dolphin is close to
something interesting:

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

Strictly speaking, the `context` keyword is a synonym for `describe`, 
but thoughtful use will make your spec easier to understand.

### Test Readability: Quick and XCTest

In [Effective Tests Using XCTest: Arrange, Act, and Assert](ArrangeActAssert.md),
we looked at how one test per condition was a great way to organize test code.
In XCTest, that leads to long test method names:

```swift
func testDolphin_click_whenTheDolphinIsNearSomethingInteresting_isEmittedThreeTimes() {
  // ...
}
```

Using Quick, the conditions are much easier to read, and we can perform setup
for each example group:

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

## Temporarily Disabling Examples or Groups

You can temporarily disable examples or example groups that don't pass yet.
The names of the examples will be printed out along with the test results,
but they won't be run.

You can disable an example or group by prepending `x`:

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

## Temporarily Running a Subset of Focused Examples

Sometimes it helps to focus on only one or a few examples. Running one
or two examples is faster than the entire suite, after all. You can
run only one or two by using the `fit` function. You can also focus a
group of examples using `fdescribe` or `fcontext`:

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

## Global Setup/Teardown Using `beforeSuite` and `afterSuite`

Some test setup needs to be performed before *any* examples are
run. For these cases, use `beforeSuite` and `afterSuite`.

In the example below, a database of all the creatures in the ocean is
created before any examples are run. That database is torn down once all
the examples have finished:

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

You can specify as many `beforeSuite` and `afterSuite` as you like. All
`beforeSuite` closures will be executed before any tests run, and all
`afterSuite` closures will be executed after all the tests are finished.
There is no guarantee as to what order these closures will be executed in.

## Accessing Metadata for the Current Example

There may be some cases in which you'd like the know the name of the example
that is currently being run, or how many have been run so far. Quick provides
access to this metadata in `beforeEach` and `afterEach` closures.

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
