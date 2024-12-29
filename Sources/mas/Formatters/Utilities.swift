//
//  Utilities.swift
//  mas
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Foundation

// A collection of output formatting helpers

/// Terminal Control Sequence Indicator.
private let csi = "\u{001B}["

private var standardError = FileHandle.standardError

extension FileHandle: TextOutputStream {
    /// Appends the given string to the stream.
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        write(data)
    }
}

/// Prints a message to stdout prefixed with a blue arrow.
func printInfo(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("==> \(message)")
        return
    }

    // Blue bold arrow, Bold text
    print("\(csi)1;34m==>\(csi)0m \(csi)1m\(message)\(csi)0m")
}

/// Prints a message to stderr prefixed with "Warning:" underlined in yellow.
func printWarning(_ message: String) {
    guard isatty(fileno(stderr)) != 0 else {
        print("Warning: \(message)", to: &standardError)
        return
    }

    // Yellow, underlined "Warning:" prefix
    print("\(csi)4;33mWarning:\(csi)0m \(message)", to: &standardError)
}

/// Prints a message to stderr prefixed with "Error:" underlined in red.
func printError(_ message: String) {
    guard isatty(fileno(stderr)) != 0 else {
        print("Error: \(message)", to: &standardError)
        return
    }

    // Red, underlined "Error:" prefix
    print("\(csi)4;31mError:\(csi)0m \(message)", to: &standardError)
}

/// Flushes stdout.
func clearLine() {
    guard isatty(fileno(stdout)) != 0 else {
        return
    }

    print("\(csi)2K\(csi)0G", terminator: "")
    fflush(stdout)
}

func captureStream(
    _ stream: UnsafeMutablePointer<FILE>,
    encoding: String.Encoding = .utf8,
    _ block: @escaping () throws -> Void
) rethrows -> String {
    let originalFd = fileno(stream)
    let duplicateFd = dup(originalFd)
    defer {
        close(duplicateFd)
    }

    let pipe = Pipe()
    dup2(pipe.fileHandleForWriting.fileDescriptor, originalFd)

    do {
        defer {
            fflush(stream)
            dup2(duplicateFd, originalFd)
            pipe.fileHandleForWriting.closeFile()
        }

        try block()
    }

    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: encoding) ?? ""
}
