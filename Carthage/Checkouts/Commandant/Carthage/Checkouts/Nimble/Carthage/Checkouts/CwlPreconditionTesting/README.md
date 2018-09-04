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
3. Add the "CwlPreconditionTesting.framework" from the "Products" folder of the CwlPreconditionTesting project's file tree to the "Copy Files (Frameworks)" build phases of any target that you want to include this module.
4. Drag the "CwlCatchException.framework" from the "Dependencies" group (within the CwlPreconditionTesting project's file tree) onto the same "Copy Files (Frameworks)" build phase (this item may be red but that shouldn't be a problem).

That third step is a little tricky if you're unfamiliar with Xcode but it involves:

a. click on your project in the file tree
b. click on the target to whih you want to add this module
c. select the "Build Phases" tab
d. if you don't already have a "Copy File" build phase with a "Destination: Frameworks", add one using the "+" button in the top left of the tab
e. click the "+" within the "Copy File (Frameworks)" phase and from the list that appears, select the "CwlPreconditionTesting.framework" (if there are multiple frameworks with the same name, look for the one that appears *above* the corresponding macOS or iOS CwlPreconditionTesting testing target).

When building using this approach, the "FetchDependencies" target will use the Swift Package Manager to download the "CwlCatchException" project from github. The download is stored in the "Build intermediates" directory for your project. Normally, you can ignore its existence but if you get any errors from the "FetchDependencies" target, you might need to clean the build folder (Hold "Option" key while selecting "Product" &rarr; "Clean Build Folder..." from the Xcode menubar).

You can use the "Package.swift" to manage the behavior of the Swift Package Manager or if you want to download dependencies manually (instead of using this behind-the-scenes use of the Swift package manager), you should delete the "FetchDependencies" target and replace the "CwlCatchException" targets with alternatives that build the dependencies in accordance with your manual download.

### Swift Package Manager

Add the following to the `dependencies` array in your "Package.swift" file:

    .Package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", majorVersion: 1),

Or, if you're using the `swift-tools-version:4.0` package manager, add the following to the `dependencies` array in your "Package.swift" file:

    .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", majorVersion: 1)

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
