# Using Quick in Objective-C

Quick works equally well in both Swift and Objective-C.

There are two notes to keep in mind when using Quick in Objective-C,
however, which are described below.

## The Optional Shorthand Syntax

Importing Quick in an Objective-C file defines macros named `it` and
`itShouldBehaveLike`, as well as functions like `context()` and `describe()`.

If the project you are testing also defines symbols with these names, you may
encounter confusing build failures. In that case, you can avoid namespace
collision by turning off Quick's optional "shorthand" syntax:

```objc
#define QUICK_DISABLE_SHORT_SYNTAX 1

@import Quick;

QuickSpecBegin(DolphinSpec)
// ...
QuickSpecEnd
```

You must define the `QUICK_DISABLE_SHORT_SYNTAX` macro *before*
importing the Quick header.

Alternatively, you may define the macro in your test target's build configuration:

![](http://d.twobitlabs.com/VFEamhvixX.png)

## Your Test Target Must Include At Least One Swift File

The Swift stdlib will not be linked into your test target, and thus
Quick will fail to execute properly, if your test target does not contain
*at least one* Swift file.

Without at least one Swift file, your tests will exit prematurely with
the following error:

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

To fix the problem, add a blank file called `SwiftSpec.swift` to your test target:

```swift
// SwiftSpec.swift

import Quick
```

> For more details on this issue, see https://github.com/Quick/Quick/issues/164.
