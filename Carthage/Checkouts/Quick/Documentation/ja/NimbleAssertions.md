# Nimble Assertions を使ってテストをより簡潔に

テストが期待した通りに動作しない時、ユニットテストは **何が問題か** を明確にすべきです。

次の関数はサルの集団から馬鹿なサルだけを取得します。

```swift
public func silliest(monkeys: [Monkey]) -> [Monkey] {
  return monkeys.filter { $0.silliness == .verySilly }
}
```

ここでこの関数に対するテストを書いてみましょう。

```swift
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
  XCTAssertTrue(contains(sillyMonkeys, kiki))
}
```

このテストは下記のメッセージとともに失敗します。

```
XCTAssertTrue failed
```

![](http://f.cl.ly/items/1G17453p47090y30203d/Screen%20Shot%202015-02-26%20at%209.08.27%20AM.png)

失敗した時は多くの情報を残すことが望ましいです。このメッセージのままではよく分かりません。
true や false だけではそれがなにか分かりません。このままではテストコードから原因を見つけるまでに時間がかかってしまいます。

## 良い失敗メッセージを残す： Part 1: XCTAssert に手動でメッセージを渡す

`XCTAssert` は失敗時にメッセージを指定することができます。

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

しかし`XCTAssert`では自分でメッセージを指定しないといけません。

## 良い失敗メッセージを残す： Part 2: Nimble Failure Messages を使う

Nimble は Assert, 失敗時のメッセージを読みやすくしてくれます。

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

Nimble では自分でメッセージを指定しなくても Nimble がとても読みやすいメッセージを返してくれます。

```
expected to contain <Monkey(name: Kiki, sillines: extremelySilly)>,
                got <[Monkey(name: Jane, silliness: verySilly)]>
```

![](http://f.cl.ly/items/3N2e3g2K3W123b1L1J0G/Screen%20Shot%202015-02-26%20at%2011.27.02%20AM.png)

失敗メッセージは何が問題かを明確にします：ここでは `kiki` が `silliest()` の戻り値に含まれることを期待していますが
このテストでは `jane` しか含まれていません。Nimble からのメッセージで何が問題かが分かりやすく伝えられるので、簡単に直すことができます。

```diff
public func silliest(monkeys: [Monkey]) -> [Monkey] {
-  return monkeys.filter { $0.silliness == .verySilly }
+  return monkeys.filter { $0.silliness == .verySilly || $0.silliness == .extremelySilly }
}
```

Nimble は具体的な失敗メッセージを返してくれる多くの種類の Assertion を提供します。
`XCTAssert` と違って毎回自分でメッセージを指定することはありません。

Nimble の全ての assertion はこちらで確認できます： [Nimble README](https://github.com/Quick/Nimble) 。
下記に幾つかの例を示します。

```swift
expect(1 + 1).to(equal(2))
expect(1.2).to(beCloseTo(1.1, within: 0.1))
expect(3) > 2
expect("seahorse").to(contain("sea"))
expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
expect(ocean.isClean).toEventually(beTruthy())
```
