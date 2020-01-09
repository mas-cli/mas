# 安装 Quick 文件模板

Quick 仓库包含了 Swift 和 Objective-C 规范的文件模板。

## Alcatraz

Quick 模板可以通过 [Alcatraz](https://github.com/supermarin/Alcatraz) 安装，这是一个 Xcode 的包管理器。只需在包管理器里搜索 Quick ：

![](http://f.cl.ly/items/3T3q0G1j0b2t1V0M0T04/Screen%20Shot%202014-06-27%20at%202.01.10%20PM.png)

## 使用 Rakefile 手动安装

如果想手动安装模板，那么只需克隆仓库并运行 rake 命令  `templates:install` ：

```sh
$ git clone git@github.com:Quick/Quick.git
$ rake templates:install
```

若要卸载模板，可以运行命令：

```sh
$ rake templates:uninstall
```


