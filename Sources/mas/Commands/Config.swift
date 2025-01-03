//
//  Config.swift
//  mas
//
//  Created by Ross Goldberg on 2025-01-03.
//  Copyright © 2024 mas-cli. All rights reserved.
//

import ArgumentParser
import CommerceKit

private let unknown = "unknown"

extension MAS {
    /// Displays mas config & related system info.
    struct Config: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display mas config & related system info"
        )

        @Flag(help: "Output as Markdown")
        var markdown = false

        /// Runs the command.
        func run() throws {
            if markdown {
                print("```text")
            }
            print(
                """
                mas ▁▁▁▁ \(Package.version)
                from ▁▁▁ \(Package.installMethod)
                origin ▁ \(Package.gitOrigin)
                rev ▁▁▁▁ \(Package.gitRevision)
                swift ▁▁ \(Package.swiftVersion)
                driver ▁ \(Package.swiftDriverVersion)
                region ▁ \(Storefront.isoRegion?.alpha2 ?? unknown)
                macos ▁▁ \(
                    ProcessInfo.processInfo.operatingSystemVersionString.dropFirst(8)
                        .replacingOccurrences(of: "Build ", with: "")
                )
                mac ▁▁▁▁ \(macModel())
                cpu ▁▁▁▁ \(cpuBrandString())
                arch ▁▁▁ \(architecture())
                """
            )
            if markdown {
                print("```")
            }
        }
    }
}

private func macModel() -> String {
    var name = [CTL_HW, HW_MODEL]

    var size = 0
    guard sysctl(&name, u_int(name.count), nil, &size, nil, 0) == 0 else {
        perror("sysctl")
        return unknown
    }

    var buffer = [CChar](repeating: 0, count: size)
    guard sysctl(&name, u_int(name.count), &buffer, &size, nil, 0) == 0 else {
        perror("sysctl")
        return unknown
    }

    return String(cString: buffer)
}

private func cpuBrandString() -> String {
    configValue("machdep.cpu.brand_string")
}

private func architecture() -> String {
    configValue("hw.machine")
}

private func configValue(_ name: String) -> String {
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

    return String(cString: buffer)
}
