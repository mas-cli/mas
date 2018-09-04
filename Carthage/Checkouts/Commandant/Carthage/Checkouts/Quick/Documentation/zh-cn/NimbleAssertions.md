# 使用 Nimble 断言，让测试更清晰

当代码不能如预期那样正常运行时，单元测试应该能够反映出问题的所在。

例如，下面这个函数能够从所给的一组猴子中筛选并返回其中的傻猴子：

```swift
public func silliest(monkeys: [Monkey]) -> [Monkey] {
  return monkeys.filter { $0.silliness == .verySilly }
}
```

现在有一个针对这个函数的单元测试：

```swift
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
  XCTAssertTrue(contains(sillyMonkeys, kiki))
}
```

这个测试运行失败，并返回以下信息：

```
XCTAssertTrue failed
```

![](http://f.cl.ly/items/1G17453p47090y30203d/Screen%20Shot%202015-02-26%20at%209.08.27%20AM.png)

我们无法从失败信息中获得有用的东西，只能说：“好吧，原本预期为真的表达式，现在却为假。但这是为什么呢？”
像这样的困惑会降低我们的效率，因为我们现在不得不花时间理解这些测试代码。

## 更好的失败返回信息，第一部分：手动设定 `XCTAssert` 的返回信息

`XCTAssert` 这个断言（Assertion）允许我们设定运行失败时的返回信息（下面简称“返回信息”），这当然有一定的作用：

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

但是，我们就不得不亲自设置这些返回信息。

## 更好的失败返回信息，第二部分：Nimble 的返回信息

Nimble 能让你的测试断言及其返回信息更便于阅读：

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

我们不需要再亲自设置返回信息，因为 Nimble 提供的信息已经非常清楚了：

```
expected to contain <Monkey(name: Kiki, sillines: ExtremelySilly)>,
                got <[Monkey(name: Jane, silliness: VerySilly)]>
```

![](http://f.cl.ly/items/3N2e3g2K3W123b1L1J0G/Screen%20Shot%202015-02-26%20at%2011.27.02%20AM.png)

这个返回信息清楚地点明了出错的地方：预期中 `kiki` 应该包含在 `silliest()` 的返回值里面，但是实际的返回值只包含 `jane` 。现在我们知道问题出在哪了，因此很容易解决问题：

```diff
public func silliest(monkeys: [Monkey]) -> [Monkey] {
-  return monkeys.filter { $0.silliness == .verySilly }
+  return monkeys.filter { $0.silliness == .verySilly || $0.silliness == .extremelySilly }
}
```

Nimble 提供了很多种类的断言，每个断言都带有清晰的返回信息。与 `XCTAssert` 不同，你不需要每次都亲自设定返回信息。

完整的 Nimble 断言列表，请参考 [Nimble README](https://github.com/Quick/Nimble) 。
下面是一些例子，先睹为快：

```swift
expect(1 + 1).to(equal(2))
expect(1.2).to(beCloseTo(1.1, within: 0.1))
expect(3) > 2
expect("seahorse").to(contain("sea"))
expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
expect(ocean.isClean).toEventually(beTruthy())
```


