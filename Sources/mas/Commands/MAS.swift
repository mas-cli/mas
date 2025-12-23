//
// MAS.swift
// mas
//
// Copyright © 2021 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

@main
struct MAS: AsyncParsableCommand, Sendable {
	static let configuration = CommandConfiguration(
		abstract: "Mac App Store command-line interface",
		version: Self.version,
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

	static var _errorPrefix: String { // swiftlint:disable:this identifier_name
		"\(mas.format(prefix: "\(errorPrefix)", format: errorFormat, for: FileHandle.standardError)) "
	}

	private static func main() async { // swiftlint:disable:this unused_declaration
		await main(nil)
	}

	private static func main(_ arguments: [String]?) async { // swiftlint:disable:this discouraged_optional_collection
		let swiftVersion = swiftVersion.prefix { $0 != " " }
		if
			UniversalSemVer(from: String(swiftVersion)).compareSemVer(to: UniversalSemVer(from: "6.2.0")) == .orderedAscending
		{
			printer.warning(
				"""
				This mas executable was built with Swift \(swiftVersion).

				Swift compilers < 6.2 (Xcode < 26) cause mas 4 to silently crash.

				The Homebrew Core mas formula thus supports only Apple Silicon (arm64) Macs, which must run macOS 15+.

				All Macs running macOS 11+, including Apple Silicon (arm64) Macs & Intel (x86_64) Macs, are supported by the\
				 mas-cli Homebrew tap mas formula, and by GitHub Releases (https://github.com/mas-cli/mas/releases).

				To avoid crashes:

				1. Uninstall all existing mas installations. e.g., to uninstall mas from Homebrew Core, run:

				brew uninstall --force mas

				2. Install mas built with Swift 6.2+. e.g., to install mas from the mas-cli Homebrew tap mas formula:

				brew install mas-cli/tap/mas

				Note: Swift 6.2 cannot build for macOS 10.15. If you run macOS 10.15, install mas 3.1, which is available from:

				https://github.com/mas-cli/mas/releases/tag/v3.1.0

				"""
			)
		}
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

	static func main<Command: ParsableCommand>(_ command: Command, _ body: (Command) throws -> Void) throws {
		do {
			try ProcessInfo.processInfo.runAsSudoEffectiveUserAndSudoEffectiveGroupIfRootEffectiveUser {
				try body(command)
			}
		} catch {
			printer.error(error: try error.failure)
		}
	}

	static func main<Command: AsyncParsableCommand & Sendable>(_ command: Command, _ body: (Command) async throws -> Void)
	async throws { // swiftformat:disable:this indent
		do {
			try await ProcessInfo.processInfo.runAsSudoEffectiveUserAndSudoEffectiveGroupIfRootEffectiveUser {
				try await body(command)
			}
		} catch {
			printer.error(error: try error.failure)
		}
	}
}

private extension Error {
	var failure: Self {
		get throws {
			guard !MAS.exitCode(for: self).isSuccess else {
				throw self
			}

			return self
		}
	}
}

extension ParsableCommand {
	static func requiresRootPrivilegesMessage(to action: String = String(describing: Self.self).lowercased()) -> String {
		"Requires root privileges to \(action) apps"
	}
}

private func cast<T>(_ instance: Any, as _: T.Type) -> T? {
	instance as? T
}
