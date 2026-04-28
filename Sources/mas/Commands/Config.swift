//
// Config.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Darwin
private import Foundation
private import JSONAST

extension MAS {
	/// Outputs mas config & related system info.
	struct Config: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output mas config & related system info",
		)

		@OptionGroup
		private var outputFormatOptionGroup: OutputFormatOptionGroup

		func run() {
			outputFormatOptionGroup.info(
				JSON.Object( // swiftformat:disable:this wrap wrapArguments
					dictionaryLiteral: // swiftlint:disable vertical_parameter_alignment_on_call
						("mas", .string(version)), // swiftformat:disable indent
						("slice", .string(runningSliceArchitecture)),
						("slices", .string(supportedSliceArchitectures.joined(separator: " "))),
						("dist", .string(distribution)),
						("origin", .string(gitOrigin)),
						("rev", .string(gitRevision)),
						("swift", .string(swiftVersion)),
						("driver", .string(swiftDriverVersion)),
						("store", .string(appStoreRegion)),
						("region", .string(macRegion)),
						("macos", .string(macOSVersion)),
						("mac", .string(configStringValue("hw.product"))),
						("cpu", .string(configStringValue("machdep.cpu.brand_string"))),
						("arch", .string(configStringValue("hw.machine"))), // swiftlint:enable vertical_parameter_alignment_on_call
				), // swiftformat:enable indent
			)
		}
	}
}

private var runningSliceArchitecture: String {
	var info = utsname()
	return unsafe uname(&info) == 0
	? unsafe withUnsafePointer(to: &info.machine) { pointer in // swiftformat:disable indent
		unsafe pointer.withMemoryRebound(
			to: CChar.self,
			capacity: unsafe MemoryLayout.size(ofValue: unsafe pointer),
			unsafe String.init(cString:),
		)
	}
	: unknown
} // swiftformat:enable indent

private var supportedSliceArchitectures: [String] {
	Bundle.main.executableArchitectures.map { archIDs in
		archIDs.map { archID in
			guard let arch = Int(exactly: archID) else {
				return "unknown_\(archID)"
			}

			return switch arch {
			case NSBundleExecutableArchitectureARM64:
				"arm64"
			case NSBundleExecutableArchitectureI386:
				"i386"
			case NSBundleExecutableArchitecturePPC:
				"ppc"
			case NSBundleExecutableArchitecturePPC64:
				"ppc64"
			case NSBundleExecutableArchitectureX86_64:
				"x86_64"
			default:
				"unknown_0x\(String(arch, radix: 16))"
			}
		}
	}
	?? .init() // swiftformat:disable:this indent
}

private var macOSVersion: String {
	.init(
		ProcessInfo.processInfo.operatingSystemVersionString.dropFirst(8).replacing("Build ", with: "", maxReplacements: 1),
	)
}

private func configStringValue(_ name: String) -> String {
	var size = 0
	guard unsafe sysctlbyname(name, nil, &size, nil, 0) == 0 else {
		unsafe perror(sysCtlByName)
		return unknown
	}

	var buffer = [CChar](repeating: 0, count: size)
	guard unsafe sysctlbyname(name, &buffer, &size, nil, 0) == 0 else {
		unsafe perror(sysCtlByName)
		return unknown
	}

	return unsafe .init(cString: &buffer)
}

private let unknown = "unknown"
private let sysCtlByName = "sysctlbyname"
