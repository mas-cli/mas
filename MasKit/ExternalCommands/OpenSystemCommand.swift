//
//  OpenSystemCommand.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/2/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// Wrapper for the external open system command.
/// https://ss64.com/osx/open.html
public struct OpenSystemCommand: ExternalCommand {
    public var binaryPath: String

    public let process = Process()

    public let stdoutPipe = Pipe()
    public let stderrPipe = Pipe()

    public init(
        binaryPath: String = "/usr/bin/open"
    ) {
        self.binaryPath = binaryPath
    }
}
