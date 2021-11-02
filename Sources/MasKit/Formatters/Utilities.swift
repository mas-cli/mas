//
//  Utilities.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Foundation

/// A collection of output formatting helpers

/// Terminal Control Sequence Indicator
let csi = "\u{001B}["

#if DEBUG

    var printObserver: ((String) -> Void)?

    // Override global print for testability.
    // See MasKitTests/OutputListener.swift.
    func print(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n"
    ) {
        if let observer = printObserver {
            let output =
                items
                .map { "\($0)" }
                .joined(separator: separator)
                .appending(terminator)
            observer(output)
        }

        var prefix = ""
        for item in items {
            Swift.print(prefix, terminator: "")
            Swift.print(item, terminator: "")
            prefix = separator
        }

        Swift.print(terminator, terminator: "")
    }

    func print<Target>(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n",
        to output: inout Target
    ) where Target: TextOutputStream {
        if let observer = printObserver {
            let output =
                items
                .map { "\($0)" }
                .joined(separator: separator)
                .appending(terminator)
            observer(output)
        }

        var prefix = ""
        for item in items {
            Swift.print(prefix, terminator: "", to: &output)
            Swift.print(item, terminator: "", to: &output)
            prefix = separator
        }

        Swift.print(terminator, terminator: "", to: &output)
    }

#endif

private var standardError = FileHandle.standardError

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        write(data)
    }
}

func printInfo(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("==> \(message)")
        return
    }

    // Blue bold arrow, Bold text
    print("\(csi)1;34m==>\(csi)0m \(csi)1m\(message)\(csi)0m")
}

public func printWarning(_ message: String) {
    guard isatty(fileno(stderr)) != 0 else {
        print("Warning: \(message)", to: &standardError)
        return
    }

    // Yellow, underlined "Warning:" prefix
    print("\(csi)4;33mWarning:\(csi)0m \(message)", to: &standardError)
}

public func printError(_ message: String) {
    guard isatty(fileno(stderr)) != 0 else {
        print("Error: \(message)", to: &standardError)
        return
    }

    // Red, underlined "Error:" prefix
    print("\(csi)4;31mError:\(csi)0m \(message)", to: &standardError)
}

func clearLine() {
    guard isatty(fileno(stdout)) != 0 else {
        return
    }

    print("\(csi)2K\(csi)0G", terminator: "")
    fflush(stdout)
}
