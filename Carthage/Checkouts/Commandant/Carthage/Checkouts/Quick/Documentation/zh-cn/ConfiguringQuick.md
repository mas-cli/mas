# 配置 Quick 的行为

你可以通过继承 `QuickConfiguration` 并且
重写 `QuickConfiguration.Type.configure()` 类方法的方式来自定义 Quick 的行为。

```swift
// Swift

import Quick

class ProjectDataTestConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    // ...set options on the configuration object here.
  }
}
```

```objc
// Objective-C

@import Quick;

QuickConfigurationBegin(ProjectDataTestConfiguration)

+ (void)configure:(Configuration *configuration) {
  // ...set options on the configuration object here.
}

QuickConfigurationEnd
```

一个项目可能包含多个配置。Quick 不保证这些配置执行的先后顺序。

## 添加全局闭包 `beforeEach` 和 `afterEach`

你可以通过使用 `QuickConfiguration.beforeEach` 和 `QuickConfiguration.afterEach` ，执行测试中每个例子运行前或运行后特定的闭包代码：

```swift
// Swift

import Quick
import Sea

class FinConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    configuration.beforeEach {
      Dorsal.sharedFin().height = 0
    }
  }
}
```

```objc
// Objective-C

@import Quick;
#import "Dorsal.h"

QuickConfigurationBegin(FinConfiguration)

+ (void)configure:(Configuration *)configuration {
  [configuration beforeEach:^{
    [Dorsal sharedFin].height = 0;
  }];
}

QuickConfigurationEnd
```

另外，Quick 允许你根据当前正在运行的例子，访问元数据：

```swift
// Swift

import Quick

class SeaConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    configuration.beforeEach { exampleMetadata in
      // ...use the example metadata object to access the current example name, and more.
    }
  }
}
```

```objc
// Objective-C

@import Quick;

QuickConfigurationBegin(SeaConfiguration)

+ (void)configure:(Configuration *)configuration {
  [configuration beforeEachWithMetadata:^(ExampleMetadata *data) {
    // ...use the example metadata object to access the current example name, and more.
  }];
}

QuickConfigurationEnd
```


