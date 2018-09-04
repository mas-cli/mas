# Configuring How Quick Behaves

You can customize how Quick behaves by subclassing `QuickConfiguration` and
overriding the `QuickConfiguration.Type.configure()` class method:

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

Projects may include several configurations. Quick does not make any
guarantee about the order in which those configurations are executed.

## Adding Global `beforeEach` and `afterEach` Closures

Using `QuickConfiguration.beforeEach` and `QuickConfiguration.afterEach`, you
can specify closures to be run before or after *every* example in a test suite:

```swift
// Swift

import Quick
import Sea

class FinConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
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

In addition, Quick allows you to access metadata regarding the current
example being run:

```swift
// Swift

import Quick

class SeaConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
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
