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
public enum CommandantError<ClientError>: ErrorType {
	/// An option was used incorrectly.
	case UsageError(description: String)

	/// An error occurred while running a command.
	case CommandError(ClientError)
}

extension CommandantError: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .UsageError(description):
			return description

		case let .CommandError(error):
			return String(error)
		}
	}
}

/// Used to represent that a ClientError will never occur.
internal enum NoError {}

/// Constructs an `InvalidArgument` error that indicates a missing value for
/// the argument by the given name.
internal func missingArgumentError<ClientError>(argumentName: String) -> CommandantError<ClientError> {
	let description = "Missing argument for \(argumentName)"
	return .UsageError(description: description)
}

/// Constructs an error by combining the example of key (and value, if applicable)
/// with the usage description.
internal func informativeUsageError<ClientError>(keyValueExample: String, usage: String) -> CommandantError<ClientError> {
	let lines = usage.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

	return .UsageError(description: lines.reduce(keyValueExample) { previous, value in
		return previous + "\n\t" + value
	})
}

/// Constructs an error that describes how to use the option, with the given
/// example of key (and value, if applicable) usage.
internal func informativeUsageError<T, ClientError>(keyValueExample: String, option: Option<T>) -> CommandantError<ClientError> {
	if option.defaultValue != nil {
		return informativeUsageError("[\(keyValueExample)]", usage: option.usage)
	} else {
		return informativeUsageError(keyValueExample, usage: option.usage)
	}
}

/// Constructs an error that describes how to use the option.
internal func informativeUsageError<T: ArgumentType, ClientError>(option: Option<T>) -> CommandantError<ClientError> {
	var example = ""

	if let key = option.key {
		example += "--\(key) "
	}

	var valueExample = ""
	if let defaultValue = option.defaultValue {
		valueExample = "\(defaultValue)"
	}

	if valueExample.isEmpty {
		example += "(\(T.name))"
	} else {
		example += valueExample
	}

	return informativeUsageError(example, option: option)
}

/// Constructs an error that describes how to use the given boolean option.
internal func informativeUsageError<ClientError>(option: Option<Bool>) -> CommandantError<ClientError> {
	precondition(option.key != nil)

	let key = option.key!

	if let defaultValue = option.defaultValue {
		return informativeUsageError((defaultValue ? "--no-\(key)" : "--\(key)"), option: option)
	} else {
		return informativeUsageError("--(no-)\(key)", option: option)
	}
}

/// Combines the text of the two errors, if they're both `UsageError`s.
/// Otherwise, uses whichever one is not (biased toward the left).
internal func combineUsageErrors<ClientError>(lhs: CommandantError<ClientError>, rhs: CommandantError<ClientError>) -> CommandantError<ClientError> {
	switch (lhs, rhs) {
	case let (.UsageError(left), .UsageError(right)):
		let combinedDescription = "\(left)\n\n\(right)"
		return .UsageError(description: combinedDescription)

	case (.UsageError, _):
		return rhs
	
	case (_, .UsageError), (_, _):
		return lhs
	}
}
