# Objective-C で Quick を使う

Quick は Swift でも Objective-C でも問題なく動作します。

ですが、Objective-C で Quick を使う場合、2点気を付けておきべきことがあります。

## 簡略記法

Objective-C で Quick を import すると `it` と `itShouldBehaveLike` というマクロが定義されます。
また、`context()` and `describe()`といった関数も同様に定義されます。

もしプロジェクトですでに同じ名前のシンボルを定義していた場合、重複のためビルドエラーになります。
その場合は下記のように`QUICK_DISABLE_SHORT_SYNTAX`を定義してこの機能を無効にしてください。

```objc
#define QUICK_DISABLE_SHORT_SYNTAX 1

@import Quick;

QuickSpecBegin(DolphinSpec)
// ...
QuickSpecEnd
```

`QUICK_DISABLE_SHORT_SYNTAX`マクロは Quick ヘッダを import する前に定義する必要があります。


## Swift のファイルを テストターゲットに含める

テストターゲットの中に Swift のファイルが含まれていないと Swift stlib が リンクされないため Quick が正しく実行されません。

Swift のファイルが含まれていないと下記のようなエラーが発生します。

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

修正するためには `SwiftSpec.swift` という名前の空のファイルをテストターゲットに追加してください。

```swift
// SwiftSpec.swift

import Quick
```

> この問題に関する詳細情報はこちら https://github.com/Quick/Quick/issues/164.
