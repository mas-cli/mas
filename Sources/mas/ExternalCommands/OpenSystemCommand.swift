//
//  OpenSystemCommand.swift
//  mas
//
//  Created by Ben Chatelain on 1/2/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Wrapper for the external open system command.
/// https://ss64.com/osx/open.html
struct OpenSystemCommand: ExternalCommand {
    var binaryPath: String

    let process = Process()

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()

    init(binaryPath: String = "/usr/bin/open") {
        self.binaryPath = binaryPath
    }
}
