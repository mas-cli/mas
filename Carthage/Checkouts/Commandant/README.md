# Commandant

Commandant is a Swift framework for parsing command-line arguments, inspired by [Argo](https://github.com/thoughtbot/Argo) (which is, in turn, inspired by the Haskell library [Aeson](http://hackage.haskell.org/package/aeson)).

[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

## Example

With Commandant, a command and its associated options could be defined as follows:

```swift
struct LogCommand: CommandProtocol {
	typealias Options = LogOptions

	let verb = "log"
	let function = "Reads the log"

	func run(_ options: Options) -> Result<(), YourErrorType> {
		// Use the parsed options to do something interesting here.
		return ()
	}
}

struct LogOptions: OptionsProtocol {
	let lines: Int
	let verbose: Bool
	let logName: String

	static func create(_ lines: Int) -> (Bool) -> (String) -> LogOptions {
		return { verbose in { logName in LogOptions(lines: lines, verbose: verbose, logName: logName) } }
	}

	static func evaluate(_ m: CommandMode) -> Result<LogOptions, CommandantError<YourErrorType>> {
		return create
			<*> m <| Option(key: "lines", defaultValue: 0, usage: "the number of lines to read from the logs")
			<*> m <| Option(key: "verbose", defaultValue: false, usage: "show verbose output")
			<*> m <| Argument(usage: "the log to read")
	}
}
```

Then, each available command should be added to a registry:

```swift
let commands = CommandRegistry<YourErrorType>()
commands.register(LogCommand())
commands.register(VersionCommand())
```

After which, arguments can be parsed by simply invoking the registry:

```swift
var arguments = CommandLine.arguments

// Remove the executable name.
assert(!arguments.isEmpty)
arguments.remove(at: 0)

if let verb = arguments.first {
	// Remove the command name.
	arguments.remove(at: 0)

	if let result = commands.run(command: verb, arguments: arguments) {
		// Handle success or failure.
	} else {
		// Unrecognized command.
	}
} else {
	// No command given.
}
```

For real-world examples, see the implementation of the [Carthage](https://github.com/Carthage/Carthage) command-line tool.

## License

Commandant is released under the [MIT license](LICENSE.md).
