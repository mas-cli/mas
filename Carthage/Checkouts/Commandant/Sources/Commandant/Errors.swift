//
//  Errors.swift
//  Commandant
//
//  Created by Justin Spahr-Summers on 2014-10-24.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import Foundation

/// Possible errors that can originate from Commandant.
///
/// `ClientError` should be the type of error (if any) that can occur when
/// running commands.
public enum CommandantError<ClientError>: Error {
	/// An option was used incorrectly.
	case usageError(description: String)

	/// An error occurred while running a command.
	case commandError(ClientError)
}

extension CommandantError: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .usageError(description):
			return description

		case let .commandError(error):
			return String(describing: error)
		}
	}
}

/// Constructs an `InvalidArgument` error that indicates a missing value for
/// the argument by the given name.
internal func missingArgumentError<ClientError>(_ argumentName: String) -> CommandantError<ClientError> {
	let description = "Missing argument for \(argumentName)"
	return .usageError(description: description)
}

/// Constructs an error by combining the example of key (and value, if applicable)
/// with the usage description.
internal func informativeUsageError<ClientError>(_ keyValueExample: String, usage: String) -> CommandantError<ClientError> {
	let lines = usage.components(separatedBy: .newlines)

	return .usageError(description: lines.reduce(keyValueExample) { previous, value in
		return previous + "\n\t" + value
	})
}

/// Combines the text of the two errors, if they're both `UsageError`s.
/// Otherwise, uses whichever one is not (biased toward the left).
internal func combineUsageErrors<ClientError>(_ lhs: CommandantError<ClientError>, _ rhs: CommandantError<ClientError>) -> CommandantError<ClientError> {
	switch (lhs, rhs) {
	case let (.usageError(left), .usageError(right)):
		let combinedDescription = "\(left)\n\n\(right)"
		return .usageError(description: combinedDescription)

	case (.usageError, _):
		return rhs

	case (_, .usageError), (_, _):
		return lhs
	}
}

/// Constructs an error that indicates unrecognized arguments remains.
internal func unrecognizedArgumentsError<ClientError>(_ options: [String]) -> CommandantError<ClientError> {
	return .usageError(description: "Unrecognized arguments: " + options.joined(separator: ", "))
}

// MARK: Argument

/// Constructs an error that describes how to use the argument, with the given
/// example of value usage if applicable.
internal func informativeUsageError<T, ClientError>(_ valueExample: String, argument: Argument<T>) -> CommandantError<ClientError> {
	if argument.defaultValue != nil {
		return informativeUsageError("[\(valueExample)]", usage: argument.usage)
	} else {
		return informativeUsageError(valueExample, usage: argument.usage)
	}
}

/// Constructs an error that describes how to use the argument.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ argument: Argument<T>) -> CommandantError<ClientError> {
	var example = ""

	var valueExample = ""
	if argument.usageParameter != nil {
		valueExample = argument.usageParameterDescription
	} else if let defaultValue = argument.defaultValue {
		valueExample = "\(defaultValue)"
	}

	if valueExample.isEmpty {
		example += "(\(T.name))"
	} else {
		example += valueExample
	}

	return informativeUsageError(example, argument: argument)
}

/// Constructs an error that describes how to use the argument list.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ argument: Argument<[T]>) -> CommandantError<ClientError> {
	var example = ""

	var valueExample = ""
	if argument.usageParameter != nil {
		valueExample = argument.usageParameterDescription
	} else if let defaultValue = argument.defaultValue {
		valueExample = "\(defaultValue)"
	}

	if valueExample.isEmpty {
		example += "(\(T.name))"
	} else {
		example += valueExample
	}

	return informativeUsageError(example, argument: argument)
}

// MARK: Option

/// Constructs an error that describes how to use the option, with the given
/// example of key (and value, if applicable) usage.
internal func informativeUsageError<T, ClientError>(_ keyValueExample: String, option: Option<T>) -> CommandantError<ClientError> {
	return informativeUsageError("[\(keyValueExample)]", usage: option.usage)
}

/// Constructs an error that describes how to use the option.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ option: Option<T>) -> CommandantError<ClientError> {
	return informativeUsageError("--\(option.key) \(option.defaultValue)", option: option)
}

/// Constructs an error that describes how to use the option.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ option: Option<T?>) -> CommandantError<ClientError> {
	return informativeUsageError("--\(option.key) (\(T.name))", option: option)
}

/// Constructs an error that describes how to use the option.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ option: Option<[T]>) -> CommandantError<ClientError> {
	return informativeUsageError("--\(option.key) (\(option.defaultValue))", option: option)
}

/// Constructs an error that describes how to use the option.
internal func informativeUsageError<T: ArgumentProtocol, ClientError>(_ option: Option<[T]?>) -> CommandantError<ClientError> {
	return informativeUsageError("--\(option.key) (\(T.name))", option: option)
}

/// Constructs an error that describes how to use the given boolean option.
internal func informativeUsageError<ClientError>(_ option: Option<Bool>) -> CommandantError<ClientError> {
	let key = option.key
	return informativeUsageError((option.defaultValue ? "--no-\(key)" : "--\(key)"), option: option)
}
