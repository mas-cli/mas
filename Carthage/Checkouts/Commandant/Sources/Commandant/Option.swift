//
//  Option.swift
//  Commandant
//
//  Created by Justin Spahr-Summers on 2014-11-21.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import Foundation
import Result

/// Represents a record of options for a command, which can be parsed from
/// a list of command-line arguments.
///
/// This is most helpful when used in conjunction with the `Option` and `Switch`
/// types, and `<*>` and `<|` combinators.
///
/// Example:
///
///		struct LogOptions: OptionsProtocol {
///			let verbosity: Int
///			let outputFilename: String
///			let shouldDelete: Bool
///			let logName: String
///
///			static func create(_ verbosity: Int) -> (String) -> (Bool) -> (String) -> LogOptions {
///				return { outputFilename in { shouldDelete in { logName in LogOptions(verbosity: verbosity, outputFilename: outputFilename, shouldDelete: shouldDelete, logName: logName) } } }
///			}
///
///			static func evaluate(_ m: CommandMode) -> Result<LogOptions, CommandantError<YourErrorType>> {
///				return create
///					<*> m <| Option(key: "verbose", defaultValue: 0, usage: "the verbosity level with which to read the logs")
///					<*> m <| Option(key: "outputFilename", defaultValue: "", usage: "a file to print output to, instead of stdout")
///					<*> m <| Switch(flag: "d", key: "delete", usage: "delete the logs when finished")
///					<*> m <| Argument(usage: "the log to read")
///			}
///		}
public protocol OptionsProtocol {
	associatedtype ClientError: Error

	/// Evaluates this set of options in the given mode.
	///
	/// Returns the parsed options or a `UsageError`.
	static func evaluate(_ m: CommandMode) -> Result<Self, CommandantError<ClientError>>
}

/// An `OptionsProtocol` that has no options.
public struct NoOptions<ClientError: Error>: OptionsProtocol {
	public init() {}
	
	public static func evaluate(_ m: CommandMode) -> Result<NoOptions, CommandantError<ClientError>> {
		return .success(NoOptions())
	}
}

/// Describes an option that can be provided on the command line.
public struct Option<T> {
	/// The key that controls this option. For example, a key of `verbose` would
	/// be used for a `--verbose` option.
	public let key: String

	/// The default value for this option. This is the value that will be used
	/// if the option is never explicitly specified on the command line.
	public let defaultValue: T

	/// A human-readable string describing the purpose of this option. This will
	/// be shown in help messages.
	///
	/// For boolean operations, this should describe the effect of _not_ using
	/// the default value (i.e., what will happen if you disable/enable the flag
	/// differently from the default).
	public let usage: String

	public init(key: String, defaultValue: T, usage: String) {
		self.key = key
		self.defaultValue = defaultValue
		self.usage = usage
	}
}

extension Option: CustomStringConvertible {
	public var description: String {
		return "--\(key)"
	}
}

// MARK: - Operators

// Inspired by the Argo library:
// https://github.com/thoughtbot/Argo
/*
	Copyright (c) 2014 thoughtbot, inc.

	MIT License

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
infix operator <*> : LogicalDisjunctionPrecedence

infix operator <| : MultiplicationPrecedence

/// Applies `f` to the value in the given result.
///
/// In the context of command-line option parsing, this is used to chain
/// together the parsing of multiple arguments. See OptionsProtocol for an example.
public func <*> <T, U, ClientError>(f: (T) -> U, value: Result<T, CommandantError<ClientError>>) -> Result<U, CommandantError<ClientError>> {
	return value.map(f)
}

/// Applies the function in `f` to the value in the given result.
///
/// In the context of command-line option parsing, this is used to chain
/// together the parsing of multiple arguments. See OptionsProtocol for an example.
public func <*> <T, U, ClientError>(f: Result<((T) -> U), CommandantError<ClientError>>, value: Result<T, CommandantError<ClientError>>) -> Result<U, CommandantError<ClientError>> {
	switch (f, value) {
	case let (.failure(left), .failure(right)):
		return .failure(combineUsageErrors(left, right))

	case let (.failure(left), .success):
		return .failure(left)

	case let (.success, .failure(right)):
		return .failure(right)

	case let (.success(f), .success(value)):
		let newValue = f(value)
		return .success(newValue)
	}
}

extension CommandMode {
	/// Evaluates the given option in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the option's `defaultValue` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, option: Option<T>) -> Result<T, CommandantError<ClientError>> {
		let wrapped = Option<T?>(key: option.key, defaultValue: option.defaultValue, usage: option.usage)
		// Since we are passing a non-nil default value, we can safely unwrap the
		// result.
		return (mode <| wrapped).map { $0! }
	}

	/// Evaluates the given option in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, `nil` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, option: Option<T?>) -> Result<T?, CommandantError<ClientError>> {
		let key = option.key
		switch mode {
		case let .arguments(arguments):
			var stringValue: String?
			switch arguments.consumeValue(forKey: key) {
			case let .success(value):
				stringValue = value

			case let .failure(error):
				switch error {
				case let .usageError(description):
					return .failure(.usageError(description: description))

				case .commandError:
					fatalError("CommandError should be impossible when parameterized over NoError")
				}
			}

			if let stringValue = stringValue {
				if let value = T.from(string: stringValue) {
					return .success(value)
				}
				
				let description = "Invalid value for '--\(key)': \(stringValue)"
				return .failure(.usageError(description: description))
			} else {
				return .success(option.defaultValue)
			}

		case .usage:
			return .failure(informativeUsageError(option))
		}
	}

	/// Evaluates the given option in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the option's `defaultValue` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, option: Option<[T]>) -> Result<[T], CommandantError<ClientError>> {
		let wrapped = Option<[T]?>(key: option.key, defaultValue: option.defaultValue, usage: option.usage)
		// Since we are passing a non-nil default value, we can safely unwrap the
		// result.
		return (mode <| wrapped).map { $0! }
	}

	/// Evaluates the given option in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, `nil` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, option: Option<[T]?>) -> Result<[T]?, CommandantError<ClientError>> {
		let key = option.key

		switch mode {
		case let .arguments(arguments):
			let stringValue: String?
			switch arguments.consumeValue(forKey: key) {
			case let .success(value):
				stringValue = value

			case let .failure(error):
				switch error {
				case let .usageError(description):
					return .failure(.usageError(description: description))

				case .commandError:
					fatalError("CommandError should be impossible when parameterized over NoError")
				}
			}

			guard let unwrappedStringValue = stringValue else {
				return .success(option.defaultValue)
			}

			let components = unwrappedStringValue.split(
				omittingEmptySubsequences: true,
				whereSeparator: [",", " "].contains
			)
			var resultValues: [T] = []
			for component in components {
				guard let value = T.from(string: String(component)) else {
					let description = "Invalid value for '--\(key)': \(unwrappedStringValue)"
					return .failure(.usageError(description: description))
				}
				resultValues.append(value)
			}
			return .success(resultValues)

		case .usage:
			return .failure(informativeUsageError(option))
		}
	}

	/// Evaluates the given boolean option in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the option's `defaultValue` is used.
	public static func <| <ClientError>(mode: CommandMode, option: Option<Bool>) -> Result<Bool, CommandantError<ClientError>> {
		switch mode {
		case let .arguments(arguments):
			if let value = arguments.consumeBoolean(forKey: option.key) {
				return .success(value)
			} else {
				return .success(option.defaultValue)
			}

		case .usage:
			return .failure(informativeUsageError(option))
		}
	}
}
