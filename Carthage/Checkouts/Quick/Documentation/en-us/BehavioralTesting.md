# Don't Test Code, Instead Verify Behavior

Tests should only fail if the application **behaves differently**.
They should test *what* the application code does, not *how* it does those things.

- Tests that verify *what* an application does are **behavioral tests**.
- Tests that break if the application code changes, even if the behavior
  remains the same, are **brittle tests**.

Let's say we have a banana database, called `GorillaDB`.
`GorillaDB` is a key-value store for bananas. We can save bananas:

```swift
let database = GorillaDB()
let banana = Banana()
database.save(banana: banana, key: "my-banana")
```

And we can restore bananas from disk later:

```swift
let banana = database.load(key: "my-banana")
```

## Brittle Tests

How can we test this behavior? One way would be to check the size of the database
after we save a banana:

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


Imagine, however, that the source code of `GorillaDB` changes. In order to make
reading bananas from the database faster, it maintains a cache of the most frequently
used bananas. `GorillaDB.size` grows as the size of the cache grows, and our test fails:

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/Screenshot_database_size_fail.png)

## Behavioral Tests

The key to writing behavioral tests is determining exactly what you're expecting
your application code to do.

In the context of our `testSave_savesTheBananaToTheDatabase` test: what is the
behavior we expect when we "save" a banana to the database? "Saving" implies, to me,
that we can load it later. So instead of testing that the size of the database increases,
we should test that we can load a banana.

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

The key to writing behavioral tests is asking:

- What exactly should this application code do?
- Is my test verifying *only* that behavior?
  Or could it fail due to other aspects of how the code works?
