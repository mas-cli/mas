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
				slice ▁▁ \(runningSliceArchitecture)
				slices ▁ \(supportedSliceArchitectures.joined(separator: " "))
				from ▁▁▁ \(MAS.installMethod)
				origin ▁ \(MAS.gitOrigin)
				rev ▁▁▁▁ \(MAS.gitRevision)
				swift ▁▁ \(MAS.swiftVersion)
				driver ▁ \(MAS.swiftDriverVersion)
				store ▁▁ \(appStoreRegion)
				region ▁ \(macRegion)
				macos ▁▁ \(
					ProcessInfo.processInfo.operatingSystemVersionString.dropFirst(8).replacingOccurrences(of: "Build ", with: "")
				)
				mac ▁▁▁▁ \(configStringValue("hw.product"))
				cpu ▁▁▁▁ \(configStringValue("machdep.cpu.brand_string"))
				arch ▁▁▁ \(configStringValue("hw.machine"))
				"""
			)
		}
	}
}

private var runningSliceArchitecture: String {
	var info = utsname()
	return uname(&info) == 0
	? withUnsafePointer(to: &info.machine) { pointer in // swiftformat:disable indent
		pointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: pointer), String.init(cString:))
	}
	: unknown
} // swiftformat:enable indent

private var supportedSliceArchitectures: [String] {
	Bundle.main.executableArchitectures.map { archIDs in
		archIDs.map { archID in
			switch archID.intValue {
			case 0x100000c:
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
				"0x\(String(archID.intValue, radix: 16))"
			}
		}
	}
	?? [] // swiftformat:disable:this indent
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

	return String(cString: &buffer)
}

private let unknown = "unknown"
private let sysCtlByName = "sysctlbyname"
