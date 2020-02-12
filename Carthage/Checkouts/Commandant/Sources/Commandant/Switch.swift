//
//  Switch.swift
//  Commandant
//
//  Created by Neil Pankey on 3/31/15.
//  Copyright (c) 2015 Carthage. All rights reserved.
//

/// Describes a parameterless command line flag that defaults to false and can only
/// be switched on. Canonical examples include `--force` and `--recurse`.
///
/// For a boolean toggle that can be enabled and disabled use `Option<Bool>`.
public struct Switch {
	/// The key that enables this switch. For example, a key of `verbose` would be
	/// used for a `--verbose` option.
	public let key: String

	/// Optional single letter flag that enables this switch. For example, `-v` would
	/// be used as a shorthand for `--verbose`.
	///
	/// Multiple flags can be grouped together as a single argument and will split
	/// when parsing (e.g. `rm -rf` treats 'r' and 'f' as inidividual flags).
	public let flag: Character?

	/// A human-readable string describing the purpose of this option. This will
	/// be shown in help messages.
	public let usage: String

	public init(flag: Character? = nil, key: String, usage: String) {
		self.flag = flag
		self.key = key
		self.usage = usage
	}
}

extension Switch: CustomStringConvertible {
	public var description: String {
		var options = "--\(key)"
		if let flag = self.flag {
			options += "|-\(flag)"
		}
		return options
	}
}

// MARK: - Operators

extension CommandMode {
	/// Evaluates the given boolean switch in the given mode.
	///
	/// If parsing command line arguments, and no value was specified on the command
	/// line, the option's `defaultValue` is used.
	public static func <| <ClientError> (mode: CommandMode, option: Switch) -> Result<Bool, CommandantError<ClientError>> {
		switch mode {
		case let .arguments(arguments):
			var enabled = arguments.consume(key: option.key)

			if let flag = option.flag, !enabled {
				enabled = arguments.consumeBoolean(flag: flag)
			}
			return .success(enabled)

		case .usage:
			return .failure(informativeUsageError(option.description, usage: option.usage))
		}
	}
}
