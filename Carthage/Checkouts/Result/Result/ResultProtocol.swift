//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// A protocol that can be used to constrain associated types as `Result`.
public protocol ResultProtocol {
	associatedtype Value
	associatedtype Error: Swift.Error

	init(value: Value)
	init(error: Error)
	
	var result: Result<Value, Error> { get }
}

extension Result {
	/// Returns the value if self represents a success, `nil` otherwise.
	public var value: Value? {
		switch self {
		case let .success(value): return value
		case .failure: return nil
		}
	}
	
	/// Returns the error if self represents a failure, `nil` otherwise.
	public var error: Error? {
		switch self {
		case .success: return nil
		case let .failure(error): return error
		}
	}

	/// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
	public func map<U>(_ transform: (Value) -> U) -> Result<U, Error> {
		return flatMap { .success(transform($0)) }
	}

	/// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
	public func flatMap<U>(_ transform: (Value) -> Result<U, Error>) -> Result<U, Error> {
		switch self {
		case let .success(value): return transform(value)
		case let .failure(error): return .failure(error)
		}
	}

	/// Returns a Result with a tuple of the receiver and `other` values if both
	/// are `Success`es, or re-wrapping the error of the earlier `Failure`.
	public func fanout<U>(_ other: @autoclosure () -> Result<U, Error>) -> Result<(Value, U), Error> {
		return self.flatMap { left in other().map { right in (left, right) } }
	}

	/// Returns a new Result by mapping `Failure`'s values using `transform`, or re-wrapping `Success`es’ values.
	public func mapError<Error2>(_ transform: (Error) -> Error2) -> Result<Value, Error2> {
		return flatMapError { .failure(transform($0)) }
	}

	/// Returns the result of applying `transform` to `Failure`’s errors, or re-wrapping `Success`es’ values.
	public func flatMapError<Error2>(_ transform: (Error) -> Result<Value, Error2>) -> Result<Value, Error2> {
		switch self {
		case let .success(value): return .success(value)
		case let .failure(error): return transform(error)
		}
	}

	/// Returns a new Result by mapping `Success`es’ values using `success`, and by mapping `Failure`'s values using `failure`.
	public func bimap<U, Error2>(success: (Value) -> U, failure: (Error) -> Error2) -> Result<U, Error2> {
		switch self {
		case let .success(value): return .success(success(value))
		case let .failure(error): return .failure(failure(error))
		}
	}
}

extension Result {

	// MARK: Higher-order functions

	/// Returns `self.value` if this result is a .Success, or the given value otherwise. Equivalent with `??`
	public func recover(_ value: @autoclosure () -> Value) -> Value {
		return self.value ?? value()
	}

	/// Returns this result if it is a .Success, or the given result otherwise. Equivalent with `??`
	public func recover(with result: @autoclosure () -> Result<Value, Error>) -> Result<Value, Error> {
		switch self {
		case .success: return self
		case .failure: return result()
		}
	}
}

/// Protocol used to constrain `tryMap` to `Result`s with compatible `Error`s.
public protocol ErrorConvertible: Swift.Error {
	static func error(from error: Swift.Error) -> Self
}

extension Result where Result.Failure: ErrorConvertible {

	/// Returns the result of applying `transform` to `Success`es’ values, or wrapping thrown errors.
	public func tryMap<U>(_ transform: (Value) throws -> U) -> Result<U, Error> {
		return flatMap { value in
			do {
				return .success(try transform(value))
			}
			catch {
				let convertedError = Error.error(from: error)
				// Revisit this in a future version of Swift. https://twitter.com/jckarter/status/672931114944696321
				return .failure(convertedError)
			}
		}
	}
}

// MARK: - Operators

extension Result where Result.Success: Equatable, Result.Failure: Equatable {
	/// Returns `true` if `left` and `right` are both `Success`es and their values are equal, or if `left` and `right` are both `Failure`s and their errors are equal.
	public static func ==(left: Result<Value, Error>, right: Result<Value, Error>) -> Bool {
		if let left = left.value, let right = right.value {
			return left == right
		} else if let left = left.error, let right = right.error {
			return left == right
		}
		return false
	}
}

#if swift(>=4.1)
	extension Result: Equatable where Result.Success: Equatable, Result.Failure: Equatable { }
#else
	extension Result where Result.Success: Equatable, Result.Failure: Equatable {
		/// Returns `true` if `left` and `right` represent different cases, or if they represent the same case but different values.
		public static func !=(left: Result<Value, Error>, right: Result<Value, Error>) -> Bool {
			return !(left == right)
		}
	}
#endif

extension Result {
	/// Returns the value of `left` if it is a `Success`, or `right` otherwise. Short-circuits.
	public static func ??(left: Result<Value, Error>, right: @autoclosure () -> Value) -> Value {
		return left.recover(right())
	}

	/// Returns `left` if it is a `Success`es, or `right` otherwise. Short-circuits.
	public static func ??(left: Result<Value, Error>, right: @autoclosure () -> Result<Value, Error>) -> Result<Value, Error> {
		return left.recover(with: right())
	}
}

// MARK: - migration support

@available(*, unavailable, renamed: "ErrorConvertible")
public protocol ErrorProtocolConvertible: ErrorConvertible {}
