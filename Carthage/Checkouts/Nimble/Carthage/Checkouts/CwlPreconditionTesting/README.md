# CwlPreconditionTesting

A Mach exception handler, written in Swift and Objective-C, that allows `EXC_BAD_INSTRUCTION` (as raised by Swift's `assertionFailure`/`preconditionFailure`/`fatalError`) to be caught and tested.

NOTE: the iOS code runs in the simulator *only*. It is for logic testing and cannot be deployed to the device due to the Mach exception API being private on iOS.

For an extended discussion of this code, please see the Cocoa with Love article:
	
[Partial functions in Swift, Part 2: Catching precondition failures](http://cocoawithlove.com/blog/2016/02/02/partial-functions-part-two-catching-precondition-failures.html)

## Adding to your project

This project can be used by manual inclusion in your projects or through any of the Swift Package Manager, CocoaPods or Carthage.

Minimum requirements are iOS 8 (simulator-only) or macOS 10.9. The project includes tvOS 9 and POSIX targets but these aren't regularly tested.

### Manual inclusion

1. In a subdirectory of your project's directory, run `git clone https://github.com/mattgallagher/CwlPreconditionTesting.git`
2. Drag the "CwlPreconditionTesting.xcodeproj" file from the Finder into your own project's file tree in Xcode
3. Add the "CwlPreconditionTesting.framework" from the "Products" folder of the CwlPreconditionTesting project's file tree to the "Copy Files (Frameworks)" build phases of any targets that you want to include this module.
4. Drag the "CwlCatchException.framework" from the "Dependencies" group (within the CwlPreconditionTesting project's file tree) onto the same "Copy Files (Frameworks)" build phase

### Swift Package Manager

Assuming you're using the `swift-tools-version:4.0` package manager, add the following to the `dependencies` array in your "Package.swift" file:

    .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", majorVersion: 1)

> NOTE: even though this git repository includes its dependencies in the Dependencies folder, building via the Swift Package manager fetches and builds these dependencies independently.

### CocoaPods

Add the following lines to your target in your "Podfile":

    pod 'CwlPreconditionTesting', :git => 'https://github.com/mattgallagher/CwlPreconditionTesting.git'
    pod 'CwlCatchException', :git => 'https://github.com/mattgallagher/CwlCatchException.git'

### Carthage

Add the following line to your Cartfile:

    git "https://github.com/mattgallagher/CwlPreconditionTesting.git" "master"

## Using POSIX signals and setjmp/longjmp

For comparison or for anyone running this code on a platform without Mach exceptions or the Objective-C runtime, I've added a proof-of-concept implementation of `catchBadInstruction` that uses a POSIX SIGILL `sigaction` and `setjmp`/`longjmp` to perform the throw.

In Xcode, you can simply select the CwlPreconditionTesting_POSIX target (instead of the OSX or iOS targets). If you're building without Xcode: all you need is the CwlCatchBadInstructionPOSIX.swift file (compared to the Mach exception handler, the code is tiny doesn't have any weird Objective-C/MiG file dependencies).

**Warning No. 1**: on OS X, this approach can't be used when lldb is attached since lldb's Mach exception handler blocks the SIGILL from ever occurring (I've disabled the "Debug Executable" setting for the tests in Xcode - re-enable it to witness the problem).

**Warning No. 2**: if you're switching between the CwlPreconditionTesting_OSX and CwlPreconditionTesting_POSIX targets, Xcode (as of Xcode 7.2.1) will not detect the change and will not remove the old framework correctly so you'll need to *clean your project* otherwise the old framework will hang around.

Additional problems in decreasing severity include:

* the signal handler is whole process (rather than correctly scoped to the thread where the "catch" occurs)
* the signal handler doesn't deal with re-entrancy whereas the mach exception handler remains deterministic in the face of multiple fatal errors
* the signal handler overwrites the "[red zone](https://en.wikipedia.org/wiki/Red_zone_(computing))" which is technically frowned upon in signal handlers (although unlikely to cause problems here)
