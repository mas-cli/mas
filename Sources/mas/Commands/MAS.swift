//
// MAS.swift
// mas
//
// Copyright © 2021 mas-cli. All rights reserved.
//

internal import ArgumentParser
internal import Foundation

@main
struct MAS: AsyncParsableCommand, Sendable {
	static let configuration = CommandConfiguration(
		abstract: "Mac App Store command-line interface",
		version: Self.version,
		subcommands: [
			Config.self,
			Get.self,
			Home.self,
			Install.self,
			List.self,
			Lookup.self,
			Lucky.self,
			Open.self,
			Outdated.self,
			Reset.self,
			Search.self,
			Seller.self,
			SignOut.self,
			Uninstall.self,
			Update.self,
			Version.self,
		],
	)

	static let printer = Printer()

	static var _errorPrefix: String { // swiftlint:disable:this identifier_name
		"\(format(prefix: "\(errorPrefix)", format: errorFormat, for: FileHandle.standardError)) "
	}

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

private let applicationsFolderPath = "/Applications"
private let applicationsFolderURL = URL(filePath: applicationsFolderPath, directoryHint: .isDirectory)

let applicationsFolderURLs = UserDefaults(suiteName: "com.apple.appstored")?
.dictionary(forKey: "PreferredVolume")?["name"] // swiftformat:disable indent
.map { [applicationsFolderURL, URL(filePath: "/Volumes/\($0)\(applicationsFolderPath)", directoryHint: .isDirectory)] }
?? [applicationsFolderURL]
// swiftformat:enable indent
