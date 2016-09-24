//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// An enum representing either a failure with an explanatory error, or a success with a result value.
public enum Result<T, Error: Swift.Error>: ResultProtocol, CustomStringConvertible, CustomDebugStringConvertible {
	case success(T)
	case failure(Error)

	// MARK: Constructors

	/// Constructs a success wrapping a `value`.
	public init(value: T) {
		self = .success(value)
	}

	/// Constructs a failure wrapping an `error`.
	public init(error: Error) {
		self = .failure(error)
	}

	/// Constructs a result from an Optional, failing with `Error` if `nil`.
	public init(_ value: T?, failWith: @autoclosure () -> Error) {
		self = value.map(Result.success) ?? .failure(failWith())
	}

	/// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
	public init(_ f: @autoclosure () throws -> T) {
		self.init(attempt: f)
	}

	/// Constructs a result from a function that uses `throw`, failing with `Error` if throws.
	public init(attempt f: () throws -> T) {
		do {
			self = .success(try f())
		} catch {
			self = .failure(error as! Error)
		}
	}

	// MARK: Deconstruction

	/// Returns the value from `Success` Results or `throw`s the error.
	public func dematerialize() throws -> T {
		switch self {
		case let .success(value):
			return value
		case let .failure(error):
			throw error
		}
	}

	/// Case analysis for Result.
	///
	/// Returns the value produced by applying `ifFailure` to `Failure` Results, or `ifSuccess` to `Success` Results.
	public func analysis<Result>(ifSuccess: (T) -> Result, ifFailure: (Error) -> Result) -> Result {
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
		return analysis(
			ifSuccess: { ".success(\($0))" },
			ifFailure: { ".failure(\($0))" })
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return description
	}
}

// MARK: - Derive result from failable closure

public func materialize<T>(_ f: () throws -> T) -> Result<T, NSError> {
	return materialize(try f())
}

public func materialize<T>(_ f: @autoclosure () throws -> T) -> Result<T, NSError> {
	do {
		return .success(try f())
	} catch let error as NSError {
		return .failure(error)
	}
}

// MARK: - Cocoa API conveniences

#if !os(Linux)

/// Constructs a Result with the result of calling `try` with an error pointer.
///
/// This is convenient for wrapping Cocoa API which returns an object or `nil` + an error, by reference. e.g.:
///
///     Result.try { NSData(contentsOfURL: URL, options: .DataReadingMapped, error: $0) }
public func `try`<T>(_ function: String = #function, file: String = #file, line: Int = #line, `try`: (NSErrorPointer) -> T?) -> Result<T, NSError> {
	var error: NSError?
	return `try`(&error).map(Result.success) ?? .failure(error ?? Result<T, NSError>.error(function: function, file: file, line: line))
}

/// Constructs a Result with the result of calling `try` with an error pointer.
///
/// This is convenient for wrapping Cocoa API which returns a `Bool` + an error, by reference. e.g.:
///
///     Result.try { NSFileManager.defaultManager().removeItemAtURL(URL, error: $0) }
public func `try`(_ function: String = #function, file: String = #file, line: Int = #line, `try`: (NSErrorPointer) -> Bool) -> Result<(), NSError> {
	var error: NSError?
	return `try`(&error) ?
		.success(())
	:	.failure(error ?? Result<(), NSError>.error(function: function, file: file, line: line))
}

#endif

// MARK: - ErrorProtocolConvertible conformance
	
extension NSError: ErrorProtocolConvertible {
	public static func error(from error: Swift.Error) -> Self {
		func cast<T: NSError>(_ error: Swift.Error) -> T {
			return error as! T
		}

		return cast(error)
	}
}

// MARK: -

/// An “error” that is impossible to construct.
///
/// This can be used to describe `Result`s where failures will never
/// be generated. For example, `Result<Int, NoError>` describes a result that
/// contains an `Int`eger and is guaranteed never to be a `Failure`.
public enum NoError: Swift.Error { }

// MARK: - migration support
extension Result {
	@available(*, unavailable, renamed: "success")
	public static func Success(_: T) -> Result<T, Error> {
		fatalError()
	}

	@available(*, unavailable, renamed: "failure")
	public static func Failure(_: Error) -> Result<T, Error> {
		fatalError()
	}
}

extension NSError {
	@available(*, unavailable, renamed: "error(from:)")
	public static func errorFromErrorType(_ error: Swift.Error) -> Self {
		fatalError()
	}
}

import Foundation
