# Result

[![Build Status](https://travis-ci.org/antitypical/Result.svg?branch=master)](https://travis-ci.org/antitypical/Result)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/Result.svg)](https://cocoapods.org/)
[![Reference Status](https://www.versioneye.com/objective-c/result/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/result/references)

This is a Swift µframework providing `Result<Value, Error>`.

`Result<Value, Error>` values are either successful (wrapping `Value`) or failed (wrapping `Error`). This is similar to Swift’s native `Optional` type: `success` is like `some`, and `failure` is like `none` except with an associated `Error` value. The addition of an associated `Error` allows errors to be passed along for logging or displaying to the user.

Using this µframework instead of rolling your own `Result` type allows you to easily interface with other frameworks that also use `Result`.

## Use

Use `Result` whenever an operation has the possibility of failure. Consider the following example of a function that tries to extract a `String` for a given key from a JSON `Dictionary`.

```swift
typealias JSONObject = [String: Any]

enum JSONError: Error {
    case noSuchKey(String)
    case typeMismatch
}

func stringForKey(json: JSONObject, key: String) -> Result<String, JSONError> {
    guard let value = json[key] else {
        return .failure(.noSuchKey(key))
    }
    
    guard let value = value as? String else {
        return .failure(.typeMismatch)
    }

    return .success(value)
}
```

This function provides a more robust wrapper around the default subscripting provided by `Dictionary`. Rather than return `Any?`, it returns a `Result` that either contains the `String` value for the given key, or an `ErrorType` detailing what went wrong.

One simple way to handle a `Result` is to deconstruct it using a `switch` statement.

```swift
switch stringForKey(json, key: "email") {

case let .success(email):
    print("The email is \(email)")
    
case let .failure(.noSuchKey(key)):
    print("\(key) is not a valid key")
    
case .failure(.typeMismatch):
    print("Didn't have the right type")
}
```

Using a `switch` statement allows powerful pattern matching, and ensures all possible results are covered. Swift 2.0 offers new ways to deconstruct enums like the `if-case` statement, but be wary as such methods do not ensure errors are handled.

Other methods available for processing `Result` are detailed in the [API documentation](http://cocoadocs.org/docsets/Result/).

## Result vs. Throws

Swift 2.0 introduces error handling via throwing and catching `Error`. `Result` accomplishes the same goal by encapsulating the result instead of hijacking control flow. The `Result` abstraction enables powerful functionality such as `map` and `flatMap`, making `Result` more composable than `throw`.

Since dealing with APIs that throw is common, you can convert such functions into a `Result` by using the `materialize` method. Conversely, a `Result` can be used to throw an error by calling `dematerialize`.

## Higher Order Functions

`map` and `flatMap` operate the same as `Optional.map` and `Optional.flatMap` except they apply to `Result`.

`map` transforms a `Result` into a `Result` of a new type. It does this by taking a function that transforms the `Value` type into a new value. This transformation is only applied in the case of a `success`. In the case of a `failure`, the associated error is re-wrapped in the new `Result`.

```swift
// transforms a Result<Int, JSONError> to a Result<String, JSONError>
let idResult = intForKey(json, key:"id").map { id in String(id) }
```

Here, the final result is either the id as a `String`, or carries over the `failure` from the previous result.

`flatMap` is similar to `map` in that it transforms the `Result` into another `Result`. However, the function passed into `flatMap` must return a `Result`.

An in depth discussion of `map` and `flatMap` is beyond the scope of this documentation. If you would like a deeper understanding, read about functors and monads. This article is a good place to [start](http://www.javiersoto.me/post/106875422394).

## Integration

### Carthage

1. Add this repository as a submodule and/or [add it to your Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) if you’re using [carthage](https://github.com/Carthage/Carthage/) to manage your dependencies.
2. Drag `Result.xcodeproj` into your project or workspace.
3. Link your target against `Result.framework`.
4. Application targets should ensure that the framework gets copied into their application bundle. (Framework targets should instead require the application linking them to include Result.)

### Cocoapods

```ruby
pod 'Result', '~> 4.0.0'
```

### Swift Package Manager

```swift
import PackageDescription

let package = Package(
    name: "MyProject",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git",
                 majorVersion: 4)
    ]
)
```
