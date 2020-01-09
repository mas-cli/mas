# Clearer Tests Using Nimble Assertions

When code doesn't work the way it's supposed to, unit tests should make it
**clear** exactly what's wrong.

Take the following function which, given a bunch of monkeys, only returns
the silly monkeys in the bunch:

```swift
public func silliest(monkeys: [Monkey]) -> [Monkey] {
  return monkeys.filter { $0.silliness == .verySilly }
}
```

Now let's say we have a unit test for this function:

```swift
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
  XCTAssertTrue(contains(sillyMonkeys, kiki))
}
```

The test fails with the following failure message:

```
XCTAssertTrue failed
```

![](http://f.cl.ly/items/1G17453p47090y30203d/Screen%20Shot%202015-02-26%20at%209.08.27%20AM.png)

The failure message leaves a lot to be desired. It leaves us wondering,
"OK, so something that should have been true was false--but what?"
That confusion slows us down, since we now have to spend time deciphering test code.

## Better Failure Messages, Part 1: Manually Providing `XCTAssert` Failure Messages

`XCTAssert` assertions allow us to specify a failure message of our own, which certainly helps:

```diff
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
-  XCTAssertTrue(contains(sillyMonkeys, kiki))
+  XCTAssertTrue(contains(sillyMonkeys, kiki), "Expected sillyMonkeys to contain 'Kiki'")
}
```

But we have to write our own failure message.

## Better Failure Messages, Part 2: Nimble Failure Messages

Nimble makes your test assertions, and their failure messages, easier to read:

```diff
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
-  XCTAssertTrue(contains(sillyMonkeys, kiki), "Expected sillyMonkeys to contain 'Kiki'")
+  expect(sillyMonkeys).to(contain(kiki))
}
```

We don't have to write our own failure message--the one provided by Nimble
is already very readable:

```
expected to contain <Monkey(name: Kiki, sillines: extremelySilly)>,
                got <[Monkey(name: Jane, silliness: verySilly)]>
```

![](http://f.cl.ly/items/3N2e3g2K3W123b1L1J0G/Screen%20Shot%202015-02-26%20at%2011.27.02%20AM.png)

The failure message makes it clear what's wrong: we were expecting `kiki` to be included
in the result of `silliest()`, but the result only contains `jane`. Now that we know
exactly what's wrong, it's easy to fix the issue:

```diff
public func silliest(monkeys: [Monkey]) -> [Monkey] {
-  return monkeys.filter { $0.silliness == .verySilly }
+  return monkeys.filter { $0.silliness == .verySilly || $0.silliness == .extremelySilly }
}
```

Nimble provides many different kind of assertions, each with great failure
messages. And unlike `XCTAssert`, you don't have to type your own failure message
every time.

For the full list of Nimble assertions, check out the [Nimble README](https://github.com/Quick/Nimble).
Below is just a sample, to whet your appetite:

```swift
expect(1 + 1).to(equal(2))
expect(1.2).to(beCloseTo(1.1, within: 0.1))
expect(3) > 2
expect("seahorse").to(contain("sea"))
expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
expect(ocean.isClean).toEventually(beTruthy())
```
