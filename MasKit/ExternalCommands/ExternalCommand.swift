//
//  ExternalCommand.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/1/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// CLI command
public protocol ExternalCommand {
    var binaryPath: String { get set }

    var process: Process { get }

    var stdout: String { get }
    var stderr: String { get }
    var stdoutPipe: Pipe { get }
    var stderrPipe: Pipe { get }

    var exitCode: Int? { get }
    var succeeded: Bool { get }
    var failed: Bool { get }

    /// Runs the command.
    func run(arguments: String...) throws
}

/// Common implementation
extension ExternalCommand {
    public var stdout: String {
        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    public var stderr: String {
        let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }

    public var exitCode: Int? {
        return Int(process.terminationStatus)
    }

    public var succeeded: Bool {
        return exitCode == 0
    }

    public var failed: Bool {
        return !succeeded
    }

    /// Runs the command.
    public func run(arguments: String...) throws {
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.arguments = arguments

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: binaryPath)
            do {
                try process.run()
            } catch {
                printError("Unable to launch command")
                // return throw Error()
            }
        } else {
            process.launchPath = binaryPath
            process.launch()
        }

        process.waitUntilExit()
    }
}
