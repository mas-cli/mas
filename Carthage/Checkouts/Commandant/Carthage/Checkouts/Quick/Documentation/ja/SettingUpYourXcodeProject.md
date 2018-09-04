# テストの準備をする

Xcode7 では Command Line Tool プロジェクトを除き、デフォルトで Unit test target が生成されます。 [参照：コマンドラインツールプロジェクトでテストの準備をする](#コマンドラインツールプロジェクトでテストの準備をする)。
テストを書くためには Unit test targetから Main target のコードが使用できる必要があります。

## Swift のコードを Swift でテストする

Swift で書かれたコードをテストするためには下記2つの作業を行います。

1. プロジェクトファイル `.xcodeproj` の "defines module" を `YES` に設定します。

  * Xcode で対象のプロジェクトを開き、"Build Settings" の "Defines Modules" の 項目を "Yes" にします。

2. 各テストファイルで `@testable import YourAppModuleName` を追記します。 追記することで public, internal のシンボルにアクセスできるようになります。`private` シンボルはアクセスできないままです。

```swift
// MyAppTests.swift

import XCTest
@testable import MyModule

class MyClassTests: XCTestCase {
  // ...
}
```

> Swift のファイルを Test target に含める、という方法もありますが、不具合を引き起こす([subtle, hard-to-diagnose
errors](https://github.com/Quick/Quick/issues/91)) ことがあるためお勧めしません。

## Objective-C のコードを Swift でテストする

1. Bridging header を test target に追加します。
2. Bridging header 内で テストしたいコードを import します。

```objc
// MyAppTests-BridgingHeader.h

#import "MyClass.h"
```

これで `MyClass.h` のコードを Swift のテストコードから使用できるようになります。

## Swift のコードを Objective-C でテストする

1. テストしたい Swift のクラスと関数に`@objc`属性を付加します。
2. テストコードで Module の Swift header を import します。

```objc
@import XCTest;
#import "MyModule-Swift.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

## Objective-C のコードを Objective-C でテストする

テストコード内でテスト対象を import します。

```objc
// MyAppTests.m

@import XCTest;
#import "MyClass.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

### コマンドラインツールプロジェクトでテストの準備をする

1. プロジェクトのペインからターゲットを追加(+ボタンを押下)
2. "OS X Unit Testing Bundle" または "iOS Unit Testing Bundle" を選択
3. Main target で "Edit the scheme" を選択
4. "Test" を選択, "Info" タブで "+" をクリックして追加した testing bundle を選択
