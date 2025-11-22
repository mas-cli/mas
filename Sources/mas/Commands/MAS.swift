//
// MAS.swift
// mas
//
// Copyright © 2021 mas-cli. All rights reserved.
//

internal import ArgumentParser

@main
struct MAS: AsyncParsableCommand, Sendable {
	static let configuration = CommandConfiguration(
		abstract: "Mac App Store command-line interface",
		subcommands: [
			Account.self,
			Config.self,
			Get.self,
			Home.self,
			Install.self,
			List.self,
			Lookup.self,
			Lucky.self,
			Open.self,
			Outdated.self,
			Region.self,
			Reset.self,
			Search.self,
			Seller.self,
			SignIn.self,
			SignOut.self,
			Uninstall.self,
			Update.self,
			Version.self,
		]
	)

	static let printer = Printer()

	private static func main() async { // swiftlint:disable:this unused_declaration
		await main(nil)
	}

	private static func main(_ arguments: [String]?) async { // swiftlint:disable:this discouraged_optional_collection
		do {
			let command = try parseAsRoot(arguments)
			if let command = cast(command, as: (any AsyncParsableCommand & Sendable).self) {
				try await main(command)
			} else {
				try main(command)
			}

			let errorCount = printer.errorCount
			if errorCount > 0 {
				throw ExitCode(errorCount >= UInt64(Int32.max) ? Int32.max : Int32(errorCount))
			}
		} catch {
			exit(withError: error)
		}
	}
}

extension MAS {
	static func main(_ command: some ParsableCommand) throws {
		try main(command) { command in
			var command = command
			try command.run()
		}
	}

	static func main(_ command: some AsyncParsableCommand & Sendable) async throws {
		try await main(command) { command in
			var command = command
			try await command.run()
		}
	}

	static func main<Command: ParsableCommand, E: Error>(
		_ command: Command,
		_ body: (Command) throws(E) -> Void
	) throws(E) {
		try body(command)
	}

	static func main<Command: AsyncParsableCommand & Sendable, E: Error>(
		_ command: Command,
		_ body: (Command) async throws(E) -> Void
	) async throws(E) {
		try await body(command)
	}
}

private func cast<T>(_ instance: Any, as _: T.Type) -> T? {
	instance as? T
}
