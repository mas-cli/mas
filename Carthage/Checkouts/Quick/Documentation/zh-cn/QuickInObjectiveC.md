# 在 Objective-C 中使用 Quick

Quick 既支持 Swift ，也支持 Objective-C 。

但是，在 Objective-C 下使用 Quick 时，有以下两点需要注意。

## 可选的速记语法

在 Objective-C 文件中导入的 Quick 框架，包含了名为 `it` 和
`itShouldBehaveLike` 的宏，还包含了名为 `context()` 和 `describe()` 的函数。

如果你在测试项目的时候，也定义了同名的量或者函数，那么就会出现错误。因此，这种情况下，你可以通过禁用 Quick 的可选速记语法来避免命名冲突：

```objc
#define QUICK_DISABLE_SHORT_SYNTAX 1

@import Quick;

QuickSpecBegin(DolphinSpec)
// ...
QuickSpecEnd
```

注意，必须在 `@import Quick;` 之前，定义宏：`QUICK_DISABLE_SHORT_SYNTAX` 。

当然，你也可以选择在测试目标（target）的设置里面定义宏：

![](http://d.twobitlabs.com/VFEamhvixX.png)

## 你的测试目标必需至少包含一个 Swift 文件

如果你的测试目标没有*至少包含一个 Swift 文件*，那么 Swift 标准库就不会链接到你的测试目标，因而会导致 Quick 无法正常编译。

当没有至少包含一个 Swift 文件时，测试运行后就会终止并且返回以下错误：

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

只需要在测试目标下添加一个空的 Swift 文件，如 `SwiftSpec.swift` 就可以解决这个问题：

```swift
// SwiftSpec.swift

import Quick
```

> 更多关于这个问题的细节，请参考 https://github.com/Quick/Quick/issues/164 。


