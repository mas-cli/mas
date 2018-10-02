# 常见的安装问题

这里有一些解决方案，用来处理使用框架时遇到的一些问题。

## No such module 'Quick'

- 如果你已经运行了 `pod install` ，那么关闭并重新打开 Xcode workspace 。如果这样做还没解决问题，那么请接着进行下面的步骤。
- 删除 `~/Library/Developer/Xcode/DerivedData` **整个**目录，这里面包含了 `ModuleCache` 。
- 在 Manage Schemes 对话框中，勾选 `Quick` 、`Nimble` 、`Pods-ProjectnameTests` ，然后重新编译它们（`Cmd+B`）。

