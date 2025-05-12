//
// Printing.swift
// mas
//
// Created by Andrew Naylor on 2016-09-14.
// Copyright © 2016 Andrew Naylor. All rights reserved.
//

internal import Foundation

// A collection of output formatting helpers

/// Terminal Control Sequence Indicator.
private var csi: String { "\u{001B}[" }

// periphery:ignore
// swiftlint:disable:next unused_declaration
func print(_ items: Any..., to fileHandle: FileHandle, separator: String = " ", terminator: String = "\n") {
	print(message(items, separator: separator, terminator: terminator), to: fileHandle)
}

func print(_ message: String, to fileHandle: FileHandle) {
	if let data = message.data(using: .utf8) {
		fileHandle.write(data)
	}
}

/// Prints to stdout.
func printInfo(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	print(items, separator: separator, terminator: terminator)
}

/// Clears current line from stdout, then prints to stdout, then flushes stdout.
func printEphemeral(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	clearCurrentLine(fromStream: stdout)
	print(items, separator: separator, terminator: terminator)
	fflush(stdout)
}

/// Clears current line from stdout.
func terminateEphemeralPrinting() {
	clearCurrentLine(fromStream: stdout)
}

/// Prints to stdout prefixed with a blue arrow.
func printNotice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	if isatty(fileno(stdout)) != 0 {
		// Blue bold arrow, Bold text
		print(
			"\(csi)1;34m==>\(csi)0m \(csi)1m\(message(items, separator: separator, terminator: terminator))\(csi)0m",
			terminator: ""
		)
	} else {
		print("==> \(message(items, separator: separator, terminator: terminator))", terminator: "")
	}
}

/// Prints to stderr prefixed with "Warning:" underlined in yellow.
func printWarning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	if isatty(fileno(stderr)) != 0 {
		// Yellow, underlined "Warning:" prefix
		print(
			"\(csi)4;33mWarning:\(csi)0m \(message(items, separator: separator, terminator: terminator))",
			to: FileHandle.standardError
		)
	} else {
		print("Warning: \(message(items, separator: separator, terminator: terminator))", to: FileHandle.standardError)
	}
}

/// Prints to stderr prefixed with "Error:" underlined in red.
func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	if isatty(fileno(stderr)) != 0 {
		// Red, underlined "Error:" prefix
		print(
			"\(csi)4;31mError:\(csi)0m \(message(items, separator: separator, terminator: terminator))",
			to: FileHandle.standardError
		)
	} else {
		print("Error: \(message(items, separator: separator, terminator: terminator))", to: FileHandle.standardError)
	}
}

private func message(_ items: Any..., separator: String = " ", terminator: String = "\n") -> String {
	items.map { String(describing: $0) }.joined(separator: separator).appending(terminator)
}

func clearCurrentLine(fromStream stream: UnsafeMutablePointer<FILE>) {
	if isatty(fileno(stream)) != 0 {
		print(csi, "2K", csi, "0G", separator: "", terminator: "")
		fflush(stream)
	}
}
