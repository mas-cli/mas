//
//  Command.swift
//  Commandant
//
//  Created by Justin Spahr-Summers on 2014-10-10.
//  Copyright (c) 2014 Carthage. All rights reserved.
//

import Foundation
import Result

/// Represents a subcommand that can be executed with its own set of arguments.
public protocol CommandProtocol {
	
	/// The command's options type.
	associatedtype Options: OptionsProtocol

	associatedtype ClientError: Error = Options.ClientError
	
	/// The action that users should specify to use this subcommand (e.g.,
	/// `help`).
	var verb: String { get }

	/// A human-readable, high-level description of what this command is used
	/// for.
	var function: String { get }

	/// Runs this subcommand with the given options.
	func run(_ options: Options) -> Result<(), ClientError>
}

/// A type-erased command.
public struct CommandWrapper<ClientError: Error> {
	public let verb: String
	public let function: String
	
	public let run: (ArgumentParser) -> Result<(), CommandantError<ClientError>>
	
	public let usage: () -> CommandantError<ClientError>?

	/// Creates a command that wraps another.
	fileprivate init<C: CommandProtocol>(_ command: C) where C.ClientError == ClientError, C.Options.ClientError == ClientError {
		verb = command.verb
		function = command.function
		run = { (arguments: ArgumentParser) -> Result<(), CommandantError<ClientError>> in
			let options = C.Options.evaluate(.arguments(arguments))

			if let remainingArguments = arguments.remainingArguments {
				return .failure(unrecognizedArgumentsError(remainingArguments))
			}

			switch options {
			case let .success(options):
				return command
					.run(options)
					.mapError(CommandantError.commandError)

			case let .failure(error):
				return .failure(error)
			}
		}
		usage = { () -> CommandantError<ClientError>? in
			return C.Options.evaluate(.usage).error
		}
	}
}

/// Describes the "mode" in which a command should run.
public enum CommandMode {
	/// Options should be parsed from the given command-line arguments.
	case arguments(ArgumentParser)

	/// Each option should record its usage information in an error, for
	/// presentation to the user.
	case usage
}

/// Maintains the list of commands available to run.
public final class CommandRegistry<ClientError: Error> {
	private var commandsByVerb: [String: CommandWrapper<ClientError>] = [:]

	/// All available commands.
	public var commands: [CommandWrapper<ClientError>] {
		return commandsByVerb.values.sorted { return $0.verb < $1.verb }
	}

	public init() {}

	/// Registers the given commands, making those available to run.
	///
	/// If another commands were already registered with the same `verb`s, those
	/// will be overwritten.
	@discardableResult
	public func register<C: CommandProtocol>(_ commands: C...)
		-> CommandRegistry
		where C.ClientError == ClientError, C.Options.ClientError == ClientError
	{
		for command in commands {
			commandsByVerb[command.verb] = CommandWrapper(command)
		}
		return self
	}

	/// Runs the command corresponding to the given verb, passing it the given
	/// arguments.
	///
	/// Returns the results of the execution, or nil if no such command exists.
	public func run(command verb: String, arguments: [String]) -> Result<(), CommandantError<ClientError>>? {
		return self[verb]?.run(ArgumentParser(arguments))
	}

	/// Returns the command matching the given verb, or nil if no such command
	/// is registered.
	public subscript(verb: String) -> CommandWrapper<ClientError>? {
		return commandsByVerb[verb]
	}
}

extension CommandRegistry {
	/// Hands off execution to the CommandRegistry, by parsing CommandLine.arguments
	/// and then running whichever command has been identified in the argument
	/// list.
	///
	/// If the chosen command executes successfully, the process will exit with
	/// a successful exit code.
	///
	/// If the chosen command fails, the provided error handler will be invoked,
	/// then the process will exit with a failure exit code.
	///
	/// If a matching command could not be found but there is any `executable-verb`
	/// style subcommand executable in the caller's `$PATH`, the subcommand will
	/// be executed.
	///
	/// If a matching command could not be found or a usage error occurred,
	/// a helpful error message will be written to `stderr`, then the process
	/// will exit with a failure error code.
	public func main(defaultVerb: String, errorHandler: (ClientError) -> ()) -> Never  {
		main(arguments: CommandLine.arguments, defaultVerb: defaultVerb, errorHandler: errorHandler)
	}
	
	/// Hands off execution to the CommandRegistry, by parsing `arguments`
	/// and then running whichever command has been identified in the argument
	/// list.
	///
	/// If the chosen command executes successfully, the process will exit with
	/// a successful exit code.
	///
	/// If the chosen command fails, the provided error handler will be invoked,
	/// then the process will exit with a failure exit code.
	///
	/// If a matching command could not be found but there is any `executable-verb`
	/// style subcommand executable in the caller's `$PATH`, the subcommand will
	/// be executed.
	///
	/// If a matching command could not be found or a usage error occurred,
	/// a helpful error message will be written to `stderr`, then the process
	/// will exit with a failure error code.
	public func main(arguments: [String], defaultVerb: String, errorHandler: (ClientError) -> ()) -> Never  {
		assert(arguments.count >= 1)

		var arguments = arguments

		// Extract the executable name.
		let executableName = arguments.remove(at: 0)

		// use the default verb even if we have other arguments
		var verb = defaultVerb
		if let argument = arguments.first, !argument.hasPrefix("-") {
			verb = argument
			// Remove the command name.
			arguments.remove(at: 0)
		}
		
		switch run(command: verb, arguments: arguments) {
		case .success?:
			exit(EXIT_SUCCESS)

		case let .failure(error)?:
			switch error {
			case let .usageError(description):
				fputs(description + "\n", stderr)

			case let .commandError(error):
				errorHandler(error)
			}

			exit(EXIT_FAILURE)

		case nil:
			if let subcommandExecuted = executeSubcommandIfExists(executableName, verb: verb, arguments: arguments) {
				exit(subcommandExecuted)
			}

			fputs("Unrecognized command: '\(verb)'. See `\(executableName) help`.\n", stderr)
			exit(EXIT_FAILURE)
		}
	}

	/// Finds and executes a subcommand which exists in your $PATH. The executable
	/// name must be in the form of `executable-verb`.
	///
	/// - Returns: The exit status of found subcommand or nil.
	private func executeSubcommandIfExists(_ executableName: String, verb: String, arguments: [String]) -> Int32? {
		let subcommand = "\(NSString(string: executableName).lastPathComponent)-\(verb)"

		func launchTask(_ path: String, arguments: [String]) -> Int32 {
			let task = Process()
			task.launchPath = path
			task.arguments = arguments

			task.launch()
			task.waitUntilExit()

			return task.terminationStatus
		}

		guard launchTask("/usr/bin/which", arguments: [ "-s", subcommand ]) == 0 else {
			return nil
		}

		return launchTask("/usr/bin/env", arguments: [ subcommand ] + arguments)
	}
}
