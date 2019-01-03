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
    var arguments: [String] { get set }

    var process: Process { get }

    var stdout: String? { get }
    var stderr: String? { get }
    var stdoutPipe: Pipe { get }
    var stderrPipe: Pipe { get }

    var exitCode: Int? { get }
    var succeeded: Bool { get }
    var failed: Bool { get }

    /// Runs the command.
    mutating func run() throws
}

/// Common implementation
extension ExternalCommand {
    public var stdout: String? { get {
        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }}

    public var stderr: String? { get {
        let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }}

    public var exitCode: Int? { get {
        return Int(process.terminationStatus)
    }}

    public var succeeded: Bool { get {
        return exitCode == 0
    }}

    public var failed: Bool { get {
        return !succeeded
    }}

    /// Runs the command.
    public mutating func run() throws {
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.arguments = arguments

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: binaryPath)
            do {
                try process.run()
            } catch {
                printError("Unable to launch command")
                //return throw Error()
            }
        } else {
            process.launchPath = binaryPath
            process.launch()
        }

        process.waitUntilExit()
    }
}
