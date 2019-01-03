//
//  TrashCommand.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/1/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// CLI command
public struct TrashCommand: ExternalCommand {
    public var binaryPath: String
    public var arguments: [String]

    public let process = Process()

    public let stdoutPipe = Pipe()
    public let stderrPipe = Pipe()

    public init(
        binaryPath: String = "/usr/local/bin/trash",
        arguments: [String] = []
    ) {
        self.binaryPath = binaryPath
        self.arguments = arguments
    }
}
