//
//  Utilities.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

/// A collection of output formatting helpers

/// Terminal Control Sequence Indicator
let csi = "\u{001B}["

func printInfo(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("==> \(message)")
        return
    }

    // Blue bold arrow, Bold text
    print("\(csi)1;34m==>\(csi)0m \(csi)1m\(message)\(csi)0m")
}

func printWarning(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("Warning: \(message)")
        return
    }

    // Yellow, underlined "Warning:" prefix
    print("\(csi)4;33mWarning:\(csi)0m \(message)")
}

public func printError(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("Warning: \(message)")
        return
    }

    // Red, underlined "Error:" prefix
    print("\(csi)4;31mError:\(csi)0m \(message)")
}

func clearLine() {
    guard isatty(fileno(stdout)) != 0 else {
        return
    }
    print("\(csi)2K\(csi)0G", terminator: "")
    fflush(stdout)
}
