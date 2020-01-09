# 安装 Quick

> **如果你的 Xcode 版本是7.1,** 请使用新的 Quick--`v0.9.0` 写测试代码。
> 新发布的版本是基于 `swift-2.0` 这个分支开发的。



Quick 提供了定义例子和例子群的语法。 Nimble 提供了如 `expect(...).to` 的断言语法。 在写测试代码的时候，你可以使用它们中的任意一个或者同时使用它们。

下面是几种主要的方法，用来添加 Quick 支持:

1. [Git Submodules](#git-submodules)
2. [CocoaPods](#cocoapods)
3. [Carthage](#carthage)
4. [Swift Package Manager (experimental)](#swift-package-manager)

你可以选择其中一种方法，并按照下面的步骤进行。完成之后，就可以通过 `import Quick` 使你的测试支持 Quick 。

## Git Submodules

通过以下步骤可以使用 Git 的子模块(submodules) 为项目添加 Quick 和 Nimble ：

1. 添加子模块 Quick。
2. 为你的项目新建一个 `.xcworkspace` 文件，如果原本已经有这个文件，则跳过此步骤。 ([如何添加请看这里](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_an_Existing_Project_to_a_Workspace.html))
3. 把 `Quick.xcodeproj` 添加到项目的 `.xcworkspace`中。
4. 把 `Nimble.xcodeproj` 添加到项目的 `.xcworkspace`中。它所在的目录是： `path/to/Quick/Externals/Nimble`。 通过从 Quick 的依赖库中添加 Nimble (而不是直接添加为子模块)，可以确保无论所用的 Quick 是什么版本，都能使用正确版本的 Nimble 。
5. 把 `Quick.framework` 和 `Nimble.framework` 添加到项目 "build phase" 选项页的 "Link Binary with Libraries" 列表中。

首先，你需要有一个 Git 子模块的目录，如果没有的话，就创建一个。假设这个目录的名称是 "Vendor" 。

**第一步：** 下载 Quick 和 Nimble 作为 Git 的子模块：

```sh
git submodule add git@github.com:Quick/Quick.git Vendor/Quick
git submodule add git@github.com:Quick/Nimble.git Vendor/Nimble
git submodule update --init --recursive
```

**第二步：** 把下载完的 `Quick.xcodeproj` 和 `Nimble.xcodeproj` 文件添加到项目的 `.xcworkspace` 上。 例如：下图是 `Guanaco.xcworkspace` 已经添加了 Quick 和 Nimble ：

![](http://f.cl.ly/items/2b2R0e1h09003u2f0Z3U/Screen%20Shot%202015-02-27%20at%202.19.37%20PM.png)

**第三步：** 把 `Quick.framework` 添加到测试目标(target)的 `Link Binary with Libraries` 列表中。你会发现有两个 `Quick.frameworks`；其中一个是 OS X 平台的，另一个是 iOS 平台的。

![](http://cl.ly/image/2L0G0H1a173C/Screen%20Shot%202014-06-08%20at%204.27.48%20AM.png)

重复上面的步骤，添加 `Nimble.framework`。

**更新子模块：** 如果你想把 Quick 和 Nimble 模块升级到最新版本，你可以在 Quick 目录下使用 `pull` 来更新，如下：

```sh
cd /path/to/your/project/Vendor/Quick
git checkout master
git pull --rebase origin master
```

你的 Git 仓库会自动同步更改到子模块中。如果你想确保已经更新了 Quick 子模块，那么可以这样：

```sh
cd /path/to/your/project
git commit -m "Updated Quick submodule"
```

**克隆一个包含有 Quick 子模块的仓库：** 当其他人克隆了你的仓库后，他们会同时拥有这些子模块。
他们可以运行 `git submodule update` 命令：

```sh
git submodule update --init --recursive
```

更多关于子模块的内容，可以参考[这里](http://git-scm.com/book/en/Git-Tools-Submodules)。

## CocoaPods

首先，请把 CocoaPods 升级到0.36或者更高的版本，这样才能在 Swift 下使用 CocoaPods 。

然后在你的 Podfile 中添加 Quick 和 Nimble 。并且为了在 Swift 中使用 CocoaPods ，记得加上这一行： ```use_frameworks!``` 。

```rb

# Podfile

use_frameworks!

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'MyTests' do
    testing_pods
end

target 'MyUITests' do
    testing_pods
end
```

最后，下载并将 Quick 和 Nimble 导入到你的测试中：

```sh
pod install
```

### 使用 Swift 1.2 ？

最近发布的 Quick (0.4.0) 适用于 Swift 2 (Xcode 7)，但是 Nimble (1.0.0) 适用于 Swift 1.2 (Xcode 6)。

如果你想在 Xcode 6 中使用它们，请使用以下这段代码：

```sh
target 'MyTests' do
  use_frameworks!
  pod 'Quick', '~>0.3.0'
  pod 'Nimble', '~>1.0.0'
end
```

## [Carthage](https://github.com/Carthage/Carthage)

在一个项目中，测试所在的目标(target)并没有 "Embedded Binaries" 这部分内容, 因此必须把框架添加到目标的 "Link Binary With Libraries" 里，并且在 build phase 选项页中新建一条 "Copy Files" 把它们复制到目标的框架列表中。

 > 因为 Carthage 生成的是动态的框架，所以你需要有一个合法的身份标识。

1. 在 [`Cartfile.private`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfileprivate) 中添加 Quick ，如下：

    ```
    github "Quick/Quick"
    github "Quick/Nimble"
    ```

2. 运行 `carthage update`。
3. 从 `Carthage/Build/[platform]/` 目录下, 找到 Quick 框架和 Nimble 框架，把它们添加到测试目标的 "Link Binary With Libraries" 列表中：
    ![](http://i.imgur.com/pBkDDk5.png)

4. 在你的测试目标下新建一条 "Copy Files" ：
    ![](http://i.imgur.com/jZATIjQ.png)

5. 将 "Destination" 设为 "Frameworks"，然后添加这两个框架：
    ![](http://i.imgur.com/rpnyWGH.png)

注意，这并不是使用 Carthage 来管理依赖的唯一方法。更多的方法请参考 [Carthage documentation](https://github.com/Carthage/Carthage/blob/master/README.md)。

## [Swift Package Manager](https://github.com/apple/swift-package-manager)
随着 [swift.org](https://swift.org) 上一个开源项目的出现，  Swift 现在有了一个官方的包管理器。 尽管它刚问世不久，但是它首次使在非苹果平台上使用 Quick 成为了可能。经过初期的开发，现在已经可以利用 Swift Package Manager 为测试项目添加 Quick 支持了。但是由于这个包管理器正在开发中，在使用的过程中可能会出现一些问题。

在更新的帮助文档发布之前，这个项目阐述了如何在 SwiftPM 的 `Package.swift` 中添加 Quick 。

https://github.com/Quick/QuickOnLinuxExample

### (不建议) 在真实的iOS设备上运行用Quick书写的代码

为了在设备上运行 Quick 形式的代码，你需要把 `Quick.framework` 和 `Nimble.framework` 作为 `Embedded Binaries` 添加到项目目标的 `Host Application` 里。 当以二进制文件的形式把框架添加到 Xcode 中，Xcode 会自动为 App 添加 Quick 框架。

![](http://indiedev.kapsi.fi/images/embed-in-host.png)


