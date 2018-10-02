# 在项目中添加测试

除了命令行项目以外，当你在 Xcode 7 中创建新项目时，单元测试 Target 默认是包含的。[为命令行项目设置测试 Target](#setting-up-a-test-target-for-a-command-line-tool-project) 要编写单元测试，你需要能够在测试 Target 中使用主 target 代码。

## 用 Swift 测试 Swift 项目代码

为了测试用 Swift 写的代码，你需要做以下两件事：

1. 将 `.xcodeproj` 中的 "defines module" 设置为 `YES`。

  * Xcode 中具体操作方法：选中你的项目，选择 "Build Settings" 选项列表，选中 "Defines Modules" 行，修改其值为 "Yes"。

2. 在单元测试中添加 `@testable import YourAppModuleName`。这会把所有 `public` 和 `internal` (默认访问修饰符) 修饰符暴露给测试代码。但 `private` 修饰符仍旧保持私有。

```swift
// MyAppTests.swift

import XCTest
@testable import MyModule

class MyClassTests: XCTestCase {
  // ...
}
```

> 一些开发者提倡添加 Swift 源文件至测试 target。然而这会导致以下问题 [subtle, hard-to-diagnose errors](https://github.com/Quick/Quick/issues/91)，所以并不推荐。

## 使用 Swift 测试 Objective-C 项目代码

1. 给你的测试 target 添加 bridging header 文件。
2. 在 bridging header 文件中，引入待测试的代码文件。

```objc
// MyAppTests-BridgingHeader.h

#import "MyClass.h"
```

现在就可以在 Swift 测试文件中使用 `MyClass.h` 中的代码了。

## 使用 Objective-C 测试 Swift 项目代码

1. 使用 `@objc` 桥接需要使用 Objective-C 测试的 Swift 类和方法。
2. 在单元测试中引入模块的 Swift 头文件。

```objc
@import XCTest;
#import "MyModule-Swift.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

## 使用 Objective-C 测试 Objective-C 项目代码

在测试 target 中引入待测试的代码文件：

```objc
// MyAppTests.m

@import XCTest;
#import "MyClass.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

### 为命令行项目设置测试 Target

1. 在项目窗格中添加一个项目target。
2. 选择 "OS X Unit Testing Bundle"。
3. 编辑主target的 scheme。
4. 选中 "Test" 条目，单击 "Info" 下的 "+"，选择需要测试的 bundle。
