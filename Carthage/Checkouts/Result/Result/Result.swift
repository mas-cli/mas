//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// An enum representing either a failure with an explanatory error, or a success with a result value.
public enum Result<Value, Error: Swift.Error>: ResultProtocol, CustomStringConvertible, CustomDebugStringConvertible {
	case success(Value)
	case failure(Error)

	// MARK: Constructors

	/// Constructs a success wrapping a `value`.
	public init(value: Value) {
		self = .success(value)
	}

	/// Constructs a failure wrapping an `error`.
	public init(error: Error) {
		self = .failure(error)
	}

	/// Constructs a result from an `Optional`, failing with `Error` if `nil`.
	public init(_ value: Value?, failWith: @autoclosure () -> Error) {
		self = value.map(Result.success) ?? .failure(failWith())
	}

	/// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
	public init(_ f: @autoclosure () throws -> Value) {
		self.init(attempt: f)
	}

	/// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
	public init(attempt f: () throws -> Value) {
		do {
			self = .success(try f())
		} catch var error {
			if Error.self == AnyError.self {
				error = AnyError(error)
			}
			self = .failure(error as! Error)
		}
	}

	// MARK: Deconstruction

	/// Returns the value from `success` Results or `throw`s the error.
	public func dematerialize() throws -> Value {
		switch self {
		case let .success(value):
			return value
		case let .failure(error):
			throw error
		}
	}

	/// Case analysis for Result.
	///
	/// Returns the value produced by applying `ifFailure` to `failure` Results, or `ifSuccess` to `success` Results.
	public func analysis<Result>(ifSuccess: (Value) -> Result, ifFailure: (Error) -> Result) -> Result {
		switch self {
		case let .success(value):
			return ifSuccess(value)
		case let .failure(value):
			return ifFailure(value)
		}
	}

	// MARK: Errors

	/// The domain for errors constructed by Result.
	public static var errorDomain: String { return "com.antitypical.Result" }

	/// The userInfo key for source functions in errors constructed by Result.
	public static var functionKey: String { return "\(errorDomain).function" }

	/// The userInfo key for source file paths in errors constructed by Result.
	public static var fileKey: String { return "\(errorDomain).file" }

	/// The userInfo key for source file line numbers in errors constructed by Result.
	public static var lineKey: String { return "\(errorDomain).line" }

	/// Constructs an error.
	public static func error(_ message: String? = nil, function: String = #function, file: String = #file, line: Int = #line) -> NSError {
		var userInfo: [String: Any] = [
			functionKey: function,
			fileKey: file,
			lineKey: line,
		]

		if let message = message {
			userInfo[NSLocalizedDescriptionKey] = message
		}

		return NSError(domain: errorDomain, code: 0, userInfo: userInfo)
	}


	// MARK: CustomStringConvertible

	public var description: String {
		switch self {
		case let .success(value): return ".success(\(value))"
		case let .failure(error): return ".failure(\(error))"
		}
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return description
	}

	// MARK: ResultProtocol
	public var result: Result<Value, Error> {
		return self
	}
}

extension Result where Error == AnyError {
	/// Constructs a result from an expression that uses `throw`, failing with `AnyError` if throws.
	public init(_ f: @autoclosure () throws -> Value) {
		self.init(attempt: f)
	}

	/// Constructs a result from a closure that uses `throw`, failing with `AnyError` if throws.
	public init(attempt f: () throws -> Value) {
		do {
			self = .success(try f())
		} catch {
			self = .failure(AnyError(error))
		}
	}
}

// MARK: - Derive result from failable closure

@available(*, deprecated, renamed: "Result.init(attempt:)")
public func materialize<T>(_ f: () throws -> T) -> Result<T, AnyError> {
	return Result(attempt: f)
}

@available(*, deprecated, renamed: "Result.init(_:)")
public func materialize<T>(_ f: @autoclosure () throws -> T) -> Result<T, AnyError> {
	return Result(f)
}

// MARK: - ErrorConvertible conformance
	
extension NSError: ErrorConvertible {
	public static func error(from error: Swift.Error) -> Self {
		func cast<T: NSError>(_ error: Swift.Error) -> T {
			return error as! T
		}

		return cast(error)
	}
}

// MARK: - migration support

@available(*, unavailable, message: "Use the overload which returns `Result<T, AnyError>` instead")
public func materialize<T>(_ f: () throws -> T) -> Result<T, NSError> {
	fatalError()
}

@available(*, unavailable, message: "Use the overload which returns `Result<T, AnyError>` instead")
public func materialize<T>(_ f: @autoclosure () throws -> T) -> Result<T, NSError> {
	fatalError()
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

/// Constructs a `Result` with the result of calling `try` with an error pointer.
///
/// This is convenient for wrapping Cocoa API which returns an object or `nil` + an error, by reference. e.g.:
///
///     Result.try { NSData(contentsOfURL: URL, options: .dataReadingMapped, error: $0) }
@available(*, unavailable, message: "This has been removed. Use `Result.init(attempt:)` instead. See https://github.com/antitypical/Result/issues/85 for the details.")
public func `try`<T>(_ function: String = #function, file: String = #file, line: Int = #line, `try`: (NSErrorPointer) -> T?) -> Result<T, NSError> {
	fatalError()
}

/// Constructs a `Result` with the result of calling `try` with an error pointer.
///
/// This is convenient for wrapping Cocoa API which returns a `Bool` + an error, by reference. e.g.:
///
///     Result.try { NSFileManager.defaultManager().removeItemAtURL(URL, error: $0) }
@available(*, unavailable, message: "This has been removed. Use `Result.init(attempt:)` instead. See https://github.com/antitypical/Result/issues/85 for the details.")
public func `try`(_ function: String = #function, file: String = #file, line: Int = #line, `try`: (NSErrorPointer) -> Bool) -> Result<(), NSError> {
	fatalError()
}

#endif

// MARK: -

import Foundation
