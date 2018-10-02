# 别测试代码，而应该验证程序的行为

测试应该只在程序的**行为和预期的不一样**时，才不通过。测试应该测试程序的代码做了什么，而不是测试程序如何实现。

- 验证应用程序做了什么的，叫做**行为测试**。
- 即使应用程序的行为不发生变化，只要应用程序的代码发生了变化，测试就不通过的，叫做**脆性测试**。

假设我们有一个香蕉数据库，叫做 `GorillaDB`。`GorillaDB` 是一个以键－值对来储存香蕉的数据库。我们可以用这样的方式储存香蕉：

```swift
let database = GorillaDB()
let banana = Banana()
database.save(banana: banana, key: "my-banana")
```

之后可以从数据库里取回香蕉：

```swift
let banana = database.load(key: "my-banana")
```

## 脆性测试

我们如何测试这个存取的行为呢？一种方式是每当我们储存一根香蕉后就检查数据库的大小：

```swift
// GorillaDBTests.swift

func testSave_savesTheBananaToTheDatabase() {
// Arrange: Create a database and get its original size.
let database = GorillaDB()
let originalSize = database.size

// Act: Save a banana to the database.
let banana = Banana()
database.save(banana: banana, key: "test-banana")

// Assert: The size of the database should have increased by one.
XCTAssertEqual(database.size, originalSize + 1)
}
```

然而，设想一下 `GorillaDB` 的源代码发生了变化。为了从数据库里更快地取出香蕉，数据库预留了一部份缓存空间用于存放经常使用的香蕉。`GorillaDB.size` 就会随着缓存的增加而增加，这样我们的测试就不能通过了：

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/Screenshot_database_size_fail.png)

## 行为测试

编写行为测试的关键，就是准确的定位你想让你的程序代码做什么。

在我们的 `testSave_savesTheBananaToTheDatabase` 的测试中：当我们在数据库中储存一根香蕉时，我们所希望程序完成的是一个怎样的行为呢？应该是保存香蕉，即之后可以取回香蕉。因此，我们不该测试数据库大小的增加，而应该测试我们能不能从数据库里取回香蕉。

```diff
// GorillaDBTests.swift

func testSave_savesTheBananaToTheDatabase() {
// Arrange: Create a database and get its original size.
let database = GorillaDB()
-  let originalSize = database.size

// Act: Save a banana to the database.
let banana = Banana()
database.save(banana: banana, key: "test-banana")

-  // Assert: The size of the database should have increased by one.
-  XCTAssertEqual(database.size, originalSize + 1)
+  // Assert: The bananas saved to and loaded from the database should be the same.
+  XCTAssertEqual(database.load(key: "test-banana"), banana)
}
```

编写行为测试的关键，就在于思考这些问题：

- 这段程序代码是用来做什么的？
- 我的测试只验证了程序的行为吗？它可能因为代码运行的其他原因而不通过吗？
