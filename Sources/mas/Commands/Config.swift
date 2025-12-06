//
// Config.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Darwin
private import Foundation

extension MAS {
	/// Outputs mas config & related system info.
	struct Config: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output mas config & related system info"
		)

		func run() {
			printer.info(
				"""
				mas ▁▁▁▁ \(MAS.version)
				arch ▁▁▁ \(configStringValue("hw.machine"))
				from ▁▁▁ \(MAS.installMethod)
				origin ▁ \(MAS.gitOrigin)
				rev ▁▁▁▁ \(MAS.gitRevision)
				swift ▁▁ \(MAS.swiftVersion)
				driver ▁ \(MAS.swiftDriverVersion)
				region ▁ \(region)
				macos ▁▁ \(
					ProcessInfo.processInfo.operatingSystemVersionString.dropFirst(8).replacingOccurrences(of: "Build ", with: "")
				)
				mac ▁▁▁▁ \(configStringValue("hw.product"))
				cpu ▁▁▁▁ \(configStringValue("machdep.cpu.brand_string"))
				"""
			)
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

private let unknown = "unknown"
private let sysCtlByName = "sysctlbyname"
