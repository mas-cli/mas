//
// Config.swift
// mas
//
// Created by Ross Goldberg on 2025-01-03.
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

private let unknown = "unknown"

extension MAS {
	/// Displays mas config & related system info.
	struct Config: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display mas config & related system info"
		)

		@Flag(help: "Output as Markdown")
		var markdown = false

		/// Runs the command.
		func run() async {
			if markdown {
				printInfo("```text")
			}
			printInfo(
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
				printInfo("```")
			}
		}
	}
}

private func configStringValue(_ name: String) -> String {
	var size = 0
	guard sysctlbyname(name, nil, &size, nil, 0) == 0 else {
		perror("sysctlbyname")
		return unknown
	}

	var buffer = [CChar](repeating: 0, count: size)
	guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else {
		perror("sysctlbyname")
		return unknown
	}

	return String(cString: buffer, encoding: .utf8) ?? unknown
}
