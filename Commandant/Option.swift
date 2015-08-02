//
//  Option.swift
//  Commandant
//
//  Created by Justin Spahr-Summers on 2014-11-21.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import Foundation

/// Represents a record of options for a command, which can be parsed from
/// a list of command-line arguments.
///
/// This is most helpful when used in conjunction with the `Option` and `Switch`
/// types, and `<*>` and `<|` combinators.
///
/// Example:
///
///		struct LogOptions: OptionsType {
///			let verbosity: Int
///			let outputFilename: String
///			let logName: String
///
///			static func create(verbosity: Int)(outputFilename: String)(logName: String) -> LogOptions {
///				return LogOptions(verbosity: verbosity, outputFilename: outputFilename, logName: logName)
///			}
///
///			static func evaluate(m: CommandMode) -> Result<LogOptions> {
///				return create
///					<*> m <| Option(key: "verbose", defaultValue: 0, usage: "the verbosity level with which to read the logs")
///					<*> m <| Option(key: "outputFilename", defaultValue: "", usage: "a file to print output to, instead of stdout")
///					<*> m <| Switch(flag: "d", key: "delete", defaultValue: false, usage: "delete the logs when finished")
///					<*> m <| Option(usage: "the log to read")
///			}
///		}
public protocol OptionsType {
	typealias ClientError

	/// Evaluates this set of options in the given mode.
	///
	/// Returns the parsed options or a `UsageError`.
	static func evaluate(m: CommandMode) -> Result<Self, CommandantError<ClientError>>
}

/// Describes an option that can be provided on the command line.
public struct Option<T> {
	/// The key that controls this option. For example, a key of `verbose` would
	/// be used for a `--verbose` option.
	///
	/// If this is nil, this option will not have a corresponding flag, and must
	/// be specified as a plain value at the end of the argument list.
	///
	/// This must be non-nil for a boolean option.
	public let key: String?

	/// The default value for this option. This is the value that will be used
	/// if the option is never explicitly specified on the command line.
	///
	/// If this is nil, this option is always required.
	public let defaultValue: T?

	/// A human-readable string describing the purpose of this option. This will
	/// be shown in help messages.
	///
	/// For boolean operations, this should describe the effect of _not_ using
	/// the default value (i.e., what will happen if you disable/enable the flag
	/// differently from the default).
	public let usage: String

	public init(key: String? = nil, defaultValue: T? = nil, usage: String) {
		self.key = key
		self.defaultValue = defaultValue
		self.usage = usage
	}

	/// Constructs an `InvalidArgument` error that describes how the option was
	/// used incorrectly. `value` should be the invalid value given by the user.
	private func invalidUsageError<ClientError>(value: String) -> CommandantError<ClientError> {
		let description = "Invalid value for '\(self)': \(value)"
		return .UsageError(description: description)
	}
}

extension Option: CustomStringConvertible {
	public var description: String {
		if let key = key {
			return "--\(key)"
		} else {
			return usage
		}
	}
}

/// Represents a value that can be converted from a command-line argument.
public protocol ArgumentType {
	/// A human-readable name for this type.
	static var name: String { get }

	/// Attempts to parse a value from the given command-line argument.
	static func fromString(string: String) -> Self?
}

extension Int: ArgumentType {
	public static let name = "integer"

	public static func fromString(string: String) -> Int? {
		return Int(string)
	}
}

extension UInt64: ArgumentType {
    public static let name = "integer"
    
    public static func fromString(string: String) -> UInt64? {
        return UInt64(string, radix: 10)
    }
}

extension String: ArgumentType {
	public static let name = "string"

	public static func fromString(string: String) -> String? {
		return string
	}
}

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
infix operator <*> {
	associativity left
}

infix operator <| {
	associativity left
	precedence 150
}

/// Applies `f` to the value in the given result.
///
/// In the context of command-line option parsing, this is used to chain
/// together the parsing of multiple arguments. See OptionsType for an example.
public func <*> <T, U, ClientError>(f: T -> U, value: Result<T, CommandantError<ClientError>>) -> Result<U, CommandantError<ClientError>> {
	return value.map(f)
}

/// Applies the function in `f` to the value in the given result.
///
/// In the context of command-line option parsing, this is used to chain
/// together the parsing of multiple arguments. See OptionsType for an example.
public func <*> <T, U, ClientError>(f: Result<(T -> U), CommandantError<ClientError>>, value: Result<T, CommandantError<ClientError>>) -> Result<U, CommandantError<ClientError>> {
	switch (f, value) {
	case let (.Failure(left), .Failure(right)):
		return .Failure(combineUsageErrors(left, rhs: right))

	case let (.Failure(left), .Success):
		return .Failure(left)

	case let (.Success, .Failure(right)):
		return .Failure(right)

	case let (.Success(f), .Success(value)):
		let newValue = f(value)
		return .Success(newValue)
	}
}

/// Evaluates the given option in the given mode.
///
/// If parsing command line arguments, and no value was specified on the command
/// line, the option's `defaultValue` is used.
public func <| <T: ArgumentType, ClientError>(mode: CommandMode, option: Option<T>) -> Result<T, CommandantError<ClientError>> {
	switch mode {
	case let .Arguments(arguments):
		var stringValue: String?
		if let key = option.key {
			switch arguments.consumeValueForKey(key) {
			case let .Success(value):
				stringValue = value

			case let .Failure(error):
				switch error {
				case let .UsageError(description):
					return .Failure(.UsageError(description: description))

				case .CommandError:
					fatalError("CommandError should be impossible when parameterized over NoError")
				}
			}
		} else {
			stringValue = arguments.consumePositionalArgument()
		}

		if let stringValue = stringValue {
			if let value = T.fromString(stringValue) {
				return .Success(value)
			}

			return .Failure(option.invalidUsageError(stringValue))
		} else if let defaultValue = option.defaultValue {
			return .Success(defaultValue)
		} else {
			return .Failure(missingArgumentError(option.description))
		}

	case .Usage:
		return .Failure(informativeUsageError(option))
	}
}

/// Evaluates the given boolean option in the given mode.
///
/// If parsing command line arguments, and no value was specified on the command
/// line, the option's `defaultValue` is used.
public func <| <ClientError>(mode: CommandMode, option: Option<Bool>) -> Result<Bool, CommandantError<ClientError>> {
	precondition(option.key != nil)

	switch mode {
	case let .Arguments(arguments):
		if let value = arguments.consumeBooleanKey(option.key!) {
			return .Success(value)
		} else if let defaultValue = option.defaultValue {
			return .Success(defaultValue)
		} else {
			return .Failure(missingArgumentError(option.description))
		}

	case .Usage:
		return .Failure(informativeUsageError(option))
	}
}
