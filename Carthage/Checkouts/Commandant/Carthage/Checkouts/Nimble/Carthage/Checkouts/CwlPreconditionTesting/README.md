# CwlPreconditionTesting

A Mach exception handler, written in Swift and Objective-C, that allows `EXC_BAD_INSTRUCTION` (as raised by Swift's `assertionFailure`/`preconditionFailure`/`fatalError`) to be caught and tested.

NOTE: the iOS code runs in the simulator *only*. It is for logic testing and cannot be deployed to the device due to the Mach exception API being private on iOS.

For an extended discussion of this code, please see the Cocoa with Love article:
	
[Partial functions in Swift, Part 2: Catching precondition failures](http://cocoawithlove.com/blog/2016/02/02/partial-functions-part-two-catching-precondition-failures.html)

## Requirements

From version 2.0.0-beta.1, building CwlPreconditionTesting requires Swift 5 or newer and the Swift Package Manager.

For use with older versions of Swift or other package managers, [use version 1.2.0 or older](https://github.com/mattgallagher/CwlPreconditionTesting/tree/1.2.0).

## Adding to your project

Add the following to the `dependencies` array in your "Package.swift" file:

	 .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0-beta.1"))

Or by adding `https://github.com/mattgallagher/CwlPreconditionTesting.git`, version 2.0.0-beta.1 or later, to the list of Swift packages for any project in Xcode.

## Usage

On macOS and iOS you can use the regular version:

```swift
import CwlPreconditionTesting

let e = catchBadInstruction {
	precondition(false, "THIS PRECONDITION FAILURE IS EXPECTED")
}
```

on tvOS, Linux and other platforms, you can use the POSIX version:

```swift
import CwlPosixPreconditionTesting

let e = catchBadInstruction {
	precondition(false, "THIS PRECONDITION FAILURE IS EXPECTED")
}
```

**Warning**: this POSIX version can't be used when lldb is attached since lldb's Mach exception handler blocks the SIGILL from ever occurring. You should disable the "Debug Executable" setting for the tests in Xcode. The POSIX version of the signal handler is also whole process (rather than correctly scoped to the thread where the "catch" occurs).
