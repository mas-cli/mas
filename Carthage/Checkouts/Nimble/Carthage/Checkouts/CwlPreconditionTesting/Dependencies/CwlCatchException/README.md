# CwlCatchException
A simple Swift wrapper around an Objective-C `@try`/`@catch` statement that selectively catches Objective-C exceptions by `NSException` subtype, rethrowing if any caught exception is not the expected subtype.

Look at [CwlCatchExceptionTests.swift](https://github.com/mattgallagher/CwlCatchException/blob/master/Tests/CwlCatchExceptionTests/CwlCatchExceptionTests.swift) for syntax.

## Adding to your project

This project can be used by direct inclusion in your projects or through any of the Swift Package Manager, CocoaPods or Carthage.

Minimum requirements are iOS 8 or macOS 10.9.

### Manual inclusion

1. In a subdirectory of your project's directory, run `git clone https://github.com/mattgallagher/CwlCatchException.git`
2. Drag the "CwlCatchException.xcodeproj" file from the Finder into your own project's file tree in Xcode
3. Add the "CwlCatchException.framework" from the "Products" folder of the CwlCatchException project's file tree to the "Copy Files (Frameworks)" build phases of any target that you want to include this module.

That third step is a little tricky if you're unfamiliar with Xcode but it involves:

a. click on your project in the file tree
b. click on the target to whih you want to add this module
c. select the "Build Phases" tab
d. if you don't already have a "Copy File" build phase with a "Destination: Frameworks", add one using the "+" button in the top left of the tab
e. click the "+" within the "Copy File (Frameworks)" phase and from the list that appears, select the "CwlCatchException.framework" (if there are multiple frameworks with the same name, look for the one that appears *above* the corresponding macOS or iOS CwlCatchException testing target).

### Swift Package Manager

Add the following to the `dependencies` array in your "Package.swift" file:

    .Package(url: "https://github.com/mattgallagher/CwlCatchException.git", majorVersion: 1),

Or, if you're using the `swift-tools-version:4.0` package manager, add the following to the `dependencies` array in your "Package.swift" file:

    .package(url: "https://github.com/mattgallagher/CwlCatchException.git", majorVersion: 1)

### CocoaPods

Add the following to your target in your "Podfile":

    pod 'CwlCatchException', :git => 'https://github.com/mattgallagher/CwlCatchException.git'

### Carthage

Add the following line to your Cartfile:

    git "https://github.com/mattgallagher/CwlCatchException.git" "master"
