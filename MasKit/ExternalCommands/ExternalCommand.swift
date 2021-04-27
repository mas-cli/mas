//
//  ExternalCommand.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/1/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// CLI command
protocol ExternalCommand {
    var binaryPath: String { get set }

    var process: Process { get }

    var stdout: String { get }
    var stderr: String { get }
    var stdoutPipe: Pipe { get }
    var stderrPipe: Pipe { get }

    var exitCode: Int32 { get }
    var succeeded: Bool { get }
    var failed: Bool { get }

    /// Runs the command.
    func run(arguments: String...) throws
}

/// Common implementation
extension ExternalCommand {
    var stdout: String {
        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    var stderr: String {
        let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    var exitCode: Int32 {
        process.terminationStatus
    }

    var succeeded: Bool {
        process.terminationReason == .exit && exitCode == 0
    }

    var failed: Bool {
        !succeeded
    }

    /// Runs the command.
    func run(arguments: String...) throws {
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.arguments = arguments

        if #available(macOS 10.13, *) {
            process.executableURL = URL(fileURLWithPath: binaryPath)
            try process.run()
        } else {
            process.launchPath = binaryPath
            process.launch()
        }

        process.waitUntilExit()
    }
}
