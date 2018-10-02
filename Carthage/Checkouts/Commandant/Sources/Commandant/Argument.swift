//
//  Argument.swift
//  Commandant
//
//  Created by Syo Ikeda on 12/14/15.
//  Copyright (c) 2015 Carthage. All rights reserved.
//

import Result

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

	/// A human-readable string that describes this argument as a paramater shown
	/// in the list of possible parameters in help messages (e.g. for "paths", the
	/// user would see <paths…>).
	public let usageParameter: String?

	public init(defaultValue: T? = nil, usage: String, usageParameter: String? = nil) {
		self.defaultValue = defaultValue
		self.usage = usage
		self.usageParameter = usageParameter
	}

	fileprivate func invalidUsageError<ClientError>(_ value: String) -> CommandantError<ClientError> {
		let description = "Invalid value for '\(self.usageParameterDescription)': \(value)"
		return .usageError(description: description)
	}
}

extension Argument {
	/// A string describing this argument as a parameter in help messages. This falls back
	/// to `"\(self)"` if `usageParameter` is `nil`
	internal var usageParameterDescription: String {
		return self.usageParameter.map { "<\($0)>" } ?? "\(self)"
	}
}

extension Argument where T: Sequence {
	/// A string describing this argument as a parameter in help messages. This falls back
	/// to `"\(self)"` if `usageParameter` is `nil`
	internal var usageParameterDescription: String {
		return self.usageParameter.map { "<\($0)…>" } ?? "\(self)"
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
