//
//  TrashCommand.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/1/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// Wrapper for the external trash command. Relies on the "trash" command
/// from Homebrew. Trash requires el_capitan or higher for core bottles:
/// https://github.com/Homebrew/homebrew-core/blob/master/Formula/trash.rb
public struct TrashCommand: ExternalCommand {
    public var binaryPath: String

    public let process = Process()

    public let stdoutPipe = Pipe()
    public let stderrPipe = Pipe()

    public init(
        binaryPath: String = "/usr/local/bin/trash"
    ) {
        self.binaryPath = binaryPath
    }
}
