//
//  Argument.swift
//  Commandant
//
//  Created by Syo Ikeda on 12/14/15.
//  Copyright (c) 2015 Carthage. All rights reserved.
//


/// Describes an argument that can be provided on the command line.
public struct Argument<T> {
	/// The default value for this argument. This is the value that will be used
	/// if the argument is never explicitly specified on the command line.
	///
	/// If this is nil, this argument is always required.
	public let defaultValue: T?

	/// A human-readable string describing the purpose of this argument. This will
	/// be shown in help messages.
	public let usage: String

	public init(defaultValue: T? = nil, usage: String) {
		self.defaultValue = defaultValue
		self.usage = usage
	}

	fileprivate func invalidUsageError<ClientError>(_ value: String) -> CommandantError<ClientError> {
		let description = "Invalid value for '\(self)': \(value)"
		return .usageError(description: description)
	}
}

// MARK: - Operators

extension CommandMode {
	/// Evaluates the given argument in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the argument's `defaultValue` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, argument: Argument<T>) -> Result<T, CommandantError<ClientError>> {
		switch mode {
		case let .arguments(arguments):
			guard let stringValue = arguments.consumePositionalArgument() else {
				if let defaultValue = argument.defaultValue {
					return .success(defaultValue)
				} else {
					return .failure(missingArgumentError(argument.usage))
				}
			}

			if let value = T.from(string: stringValue) {
				return .success(value)
			} else {
				return .failure(argument.invalidUsageError(stringValue))
			}

		case .usage:
			return .failure(informativeUsageError(argument))
		}
	}

	/// Evaluates the given argument list in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the argument's `defaultValue` is used.
	public static func <| <T: ArgumentProtocol, ClientError>(mode: CommandMode, argument: Argument<[T]>) -> Result<[T], CommandantError<ClientError>> {
		switch mode {
		case let .arguments(arguments):
			guard let firstValue = arguments.consumePositionalArgument() else {
				if let defaultValue = argument.defaultValue {
					return .success(defaultValue)
				} else {
					return .failure(missingArgumentError(argument.usage))
				}
			}

			var values = [T]()

			guard let value = T.from(string: firstValue) else {
				return .failure(argument.invalidUsageError(firstValue))
			}

			values.append(value)

			while let nextValue = arguments.consumePositionalArgument() {
				guard let value = T.from(string: nextValue) else {
					return .failure(argument.invalidUsageError(nextValue))
				}

				values.append(value)
			}

			return .success(values)

		case .usage:
			return .failure(informativeUsageError(argument))
		}
	}
}
