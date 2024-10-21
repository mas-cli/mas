//
//  SysCtlSystemCommand.swift
//  mas
//
//  Created by Chris Araman on 6/3/21.
//  Copyright © 2021 mas-cli. All rights reserved.
//

import Foundation

/// Wrapper for the external 'sysctl' system command.
///
/// See - https://ss64.com/osx/sysctl.html
struct SysCtlSystemCommand: ExternalCommand {
    static var isAppleSilicon: Bool = {
        let sysctl = Self()
        do {
            // Returns 1 on Apple Silicon even when run in an Intel context in Rosetta.
            try sysctl.run(arguments: "-in", "hw.optional.arm64")
        } catch {
            fatalError("sysctl failed")
        }

        guard sysctl.succeeded else {
            fatalError("sysctl failed")
        }

        return sysctl.stdout.trimmingCharacters(in: .newlines) == "1"
    }()

    let process = Process()

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()

    var binaryPath: String

    init(binaryPath: String = "/usr/sbin/sysctl") {
        self.binaryPath = binaryPath
    }
}
