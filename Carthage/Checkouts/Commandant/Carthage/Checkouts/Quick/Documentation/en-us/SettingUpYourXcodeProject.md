# Setting Up Tests in Your Xcode Project

With the exception of the Command Line Tool project type, when you create a new project in Xcode 7, a unit test target is included
by default. [See specific instructions for a Command Line Tool Project](#setting-up-a-test-target-for-a-command-line-tool-project). To write unit tests, you'll need to be able to use your main
target's code from within your test target.

## Testing Swift Code Using Swift

In order to test code written in Swift, you'll need to do two things:

1. Set "Defines Module" in your `.xcodeproj` to `YES`.

  * To do this in Xcode: Choose your project, then "Build Settings", then "Packaging" header,
    then "Defines Module" line, then select "Yes". Note: you may have 
    to choose "All" (Build Settings) instead of "Basic" to see the
    "Packaging" section.

2. `@testable import YourAppModuleName` in your unit tests. This will expose Any `public` and `internal` (the default)
   symbols to your tests. `private` symbols are still unavailable.

```swift
// MyAppTests.swift

import XCTest
@testable import MyModule

class MyClassTests: XCTestCase {
  // ...
}
```

> Quick integration in the Xcode Test Navigator suffers from some limitations (open [issue](https://github.com/Quick/Quick/issues/219)). Quick tests will not show up in the navigator until they've been run, repeat runs tend to reset the list in unpredictable ways and the tests cannot be run from the gutter next to the source code.
> Please file a radar to Apple and mention this as a duplicate to [rdar://26152293](http://openradar.appspot.com/radar?id=4974047628623872) to promote this feature request for Apple Engineers.

> Some developers advocate adding Swift source files to your test target.
However, this leads to [subtle, hard-to-diagnose
errors](https://github.com/Quick/Quick/issues/91), and is not
recommended.

## Testing Objective-C Code Using Swift

1. Add a bridging header to your test target.
2. In the bridging header, import the file containing the code you'd like to test.

```objc
// MyAppTests-BridgingHeader.h

#import "MyClass.h"
```

You can now use the code from `MyClass.h` in your Swift test files.

## Testing Swift Code Using Objective-C

1. Bridge Swift classes and functions you'd like to test to Objective-C by
   using the `@objc` attribute.
2. Import your module's Swift headers in your unit tests.

```objc
@import XCTest;
#import "MyModule-Swift.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

## Testing Objective-C Code Using Objective-C

Import the file defining the code you'd like to test from within your test target:

```objc
// MyAppTests.m

@import XCTest;
#import "MyClass.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

### Setting Up a Test Target for a Command Line Tool Project

1. Add a target to your project in the project pane.
2. Select "OS X Unit Testing Bundle".
3. Edit the scheme of your main target.
4. Select the "Test" node, click the "+" under the "Info" heading, and select
   your testing bundle.
