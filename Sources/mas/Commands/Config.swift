//
// Config.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

private var unknown: String { "unknown" }
private var sysCtlByName: String { "sysctlbyname" }

extension MAS {
	/// Displays detailed configuration and environment information for `mas`.
	///
	/// This includes version info, architecture, installation method, build revision,
	/// Swift driver version, macOS version, CPU, and region settings.
	///
	/// This command is particularly useful for users and developers who need
	/// to inspect runtime environment details — for example, when reporting issues or verifying setup.
	///
	/// Use `--markdown` to output results in a Markdown-friendly format.
	///
	/// Example:
	/// ```bash
	/// mas config --markdown
	/// ```
	struct Config: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output mas config & related system info"
		)

		@Flag(help: "Output as Markdown")
		var markdown = false

		/// Runs the command.
		func run() async throws {
			try await mas.run { await run(printer: $0) }
		}

		func run(printer: Printer) async {
			if markdown {
				printer.info("```text")
			}
			printer.info(
				"""
				mas ▁▁▁▁ \(Package.version)
				arch ▁▁▁ \(configStringValue("hw.machine"))
				from ▁▁▁ \(Package.installMethod)
				origin ▁ \(Package.gitOrigin)
				rev ▁▁▁▁ \(Package.gitRevision)
				driver ▁ \(Package.swiftDriverVersion)
				swift ▁▁ \(Package.swiftVersion)
				region ▁ \(await isoRegion?.alpha2 ?? unknown)
				macos ▁▁ \(
					ProcessInfo.processInfo.operatingSystemVersionString.dropFirst(8).replacingOccurrences(of: "Build ", with: "")
				)
				mac ▁▁▁▁ \(configStringValue("hw.product"))
				cpu ▁▁▁▁ \(configStringValue("machdep.cpu.brand_string"))
				"""
			)
			if markdown {
				printer.info("```")
			}
		}
	}
}

private func configStringValue(_ name: String) -> String {
	var size = 0
	guard sysctlbyname(name, nil, &size, nil, 0) == 0 else {
		perror(sysCtlByName)
		return unknown
	}

	var buffer = [CChar](repeating: 0, count: size)
	guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else {
		perror(sysCtlByName)
		return unknown
	}

	return String(cString: buffer, encoding: .utf8) ?? unknown
}
