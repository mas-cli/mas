# Nimble Assertions를 사용하여 테스트를 더욱 간결하게 하기

코드가 예상한 대로 작동하지 않을 때, 단위 테스트는 무엇이 문제인가를 **명확하게** 만들어야 합니다.

원숭이들의 무리가 주어진다면 오직 멍청한 원숭이 무리만 반환하는 함수를 작성해 보세요 :

```swift
public func silliest(monkeys: [Monkey]) -> [Monkey] {
  return monkeys.filter { $0.silliness == .verySilly }
}
```

이제 이 함수에 대한 단위 테스트가 있다고 가정을 해 보겠습니다 :

```swift
func testSilliest_whenMonkeysContainSillyMonkeys_theyreIncludedInTheResult() {
  let kiki = Monkey(name: "Kiki", silliness: .extremelySilly)
  let carl = Monkey(name: "Carl", silliness: .notSilly)
  let jane = Monkey(name: "Jane", silliness: .verySilly)
  let sillyMonkeys = silliest([kiki, carl, jane])
  XCTAssertTrue(contains(sillyMonkeys, kiki))
}
```

테스트는 다음의 실패 메시지와 함께 실패합니다 :

```
XCTAssertTrue failed
```

![](http://f.cl.ly/items/1G17453p47090y30203d/Screen%20Shot%202015-02-26%20at%209.08.27%20AM.png)

실패 했을 때는 많은 정보를 남기는 것이 바람직합니다. 이 실패 메시지의 상태로는 잘 모르겠습니다, "그래, 성공해야 하는데, 무언가가 실패를 했네 — 그래서 뭔데??" 이대로는 우리가 테스트 코드에서 원인을 찾을 때까지 시간을 많이 소비하도록 합니다.

## 더 나은 오류 메시지, Part 1: 수동으로 `XCTAssert` 실패 메시지 제공하기

`XCTAssert` assertions 을 사용하면 사용자 임의 오류 메시지를 지정할 수 있으므로 확실히 도움이 됩니다 :

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

하지만 우리는 오류 메시지를 써야 합니다.

## 더 나은 오류 메시지, Part 2: Nimble 실패 메시지

Nimble은 테스트 assertions를 만들고, 실패 메시지를 읽기 쉽게 만듭니다 :

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

우리는 사용자 임의 실패 메시지를 작성할 필요가 없습니다 — Nimble에서 제공하는 것은 이미 읽기 매우 쉽습니다. 

```
expected to contain <Monkey(name: Kiki, sillines: ExtremelySilly)>,
                got <[Monkey(name: Jane, silliness: VerySilly)]>
```

![](http://f.cl.ly/items/3N2e3g2K3W123b1L1J0G/Screen%20Shot%202015-02-26%20at%2011.27.02%20AM.png)

실패 메시지는 무엇이 잘못되었는지 명확하게 합니다 : 우리는 `silliest()`의 결과에 `kiki` 가 포함될 것으로 예상했지만, 오직 `jane`만 포함하고 있습니다. 이제 무엇이 잘못되었는지 정확히 알고 있으므로 이 이슈를 쉽게 해결할 수 있습니다 :

```diff
public func silliest(monkeys: [Monkey]) -> [Monkey] {
-  return monkeys.filter { $0.silliness == .verySilly }
+  return monkeys.filter { $0.silliness == .verySilly || $0.silliness == .extremelySilly }
}
```

Nimble은 많은 다른 assertion을 제공하며, 각각은 큰 실패 메시지를 가지고 있습니다. `XCTAssert` 와는 달리 매번 사용자 임의 실패 메시지를 지정할 필요가 없습니다. 

Nimble assertion의 모든 리스트를 보려면, [Nimble README](https://github.com/Quick/Nimble) 을 확인하세요.
아래는 궁금해하실까 봐 준비한 예제입니다.

```swift
expect(1 + 1).to(equal(2))
expect(1.2).to(beCloseTo(1.1, within: 0.1))
expect(3) > 2
expect("seahorse").to(contain("sea"))
expect(["Atlantic", "Pacific"]).toNot(contain("Mississippi"))
expect(ocean.isClean).toEventually(beTruthy())
```
