# コードをテストせず、動作を確認する

テストはアプリケーションが**期待と異なる動作** をした時のみ失敗するようにすべきです。
アプリケーションコードが *何を* したかをテストすべきで、*どのように* したかをテストすべきではありません。

- アプリケーションが *何を* したかを確認するテストは **動作テスト(behavioral tests)** といいます。
- アプリケーションの動作が変わっていなくても、コードを変更すると失敗するようになるテストは **脆弱なテスト(brittle tests)** といいます。

ここで `GorillaDB` というバナナのデータベースを用意します。
`GorillaDB`は Key-Value 型のデータベースでバナナを保存することができます。

```swift
let database = GorillaDB()
let banana = Banana()
database.save(banana: banana, key: "my-banana")
```

そしてバナナをディスクから取り出すことができます。

```swift
let banana = database.load(key: "my-banana")
```

## 脆弱なテスト(Brittle Tests)

どのようにして動作をテストするのでしょう？一つの方法としてここではバナナを保存した後にバナナのデータベースのサイズをチェックします。

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

ここで `GorillaDB` のソースコードを変更したとします。データベースからの読み出しを速くするためにもっとも頻繁に使用するバナナをキャッシュに保持するようにします。
`GorillaDB.size` はキャッシュのサイズに合わせて大きくなります。この場合ディスクに保存しなくなるため上記のテストは失敗します。

![](https://raw.githubusercontent.com/Quick/Assets/master/Screenshots/Screenshot_database_size_fail.png)

## 動作テスト(Behavioral Tests)

動作のテストの重要なポイントは アプリケーションコードに期待する動作を明確にすることです。

`testSave_savesTheBananaToTheDatabase` というテストで期待する動作は バナナをデータベースに "保存する" ことでしょうか？
"保存する"というのは 後から読み出すことができる、という意味です。そのためデータベースのサイズが大きくなることをテストするのではなく、
バナナを読み出すことができるかをテストすべきです。


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

動作テストを書く際の重要なポイント：

- アプリケーションコードが何をすべきか明確にしているか？
- テストが *動作のみ* をテストしているか？コードの動作が他の要因で意図しない動きにならないか。
