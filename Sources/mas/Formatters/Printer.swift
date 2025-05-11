//
// Printer.swift
// mas
//
// Created by Ross Goldberg on 2025-05-10.
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Atomics
internal import Foundation

// A collection of output formatting helpers

/// Terminal Control Sequence Indicator.
private var csi: String { "\u{001B}[" }

struct Printer {
	private let errorCounter = ManagedAtomic<UInt64>(0)

	var errorCount: UInt64 { errorCounter.load(ordering: .acquiring) }

	fileprivate init() {
		// Do nothing
	}

	func log(_ message: String, to fileHandle: FileHandle) {
		if let data = message.data(using: .utf8) {
			fileHandle.write(data)
		}
	}

	/// Prints to `stdout`.
	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		print(items, separator: separator, terminator: terminator)
	}

	/// Clears current line from `stdout`, then prints to `stdout`, then flushes `stdout`.
	func ephemeral(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		clearCurrentLine(fromStream: stdout)
		print(items, separator: separator, terminator: terminator)
		fflush(stdout)
	}

	/// Clears current line from `stdout`.
	func terminateEphemeral() {
		clearCurrentLine(fromStream: stdout)
	}

	/// Prints to `stdout`; if connected to a terminal, prefixes a blue arrow.
	func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
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

	/// Prints to `stderr`; if connected to a terminal, prefixes "Warning:" underlined in yellow.
	func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		if isatty(fileno(stderr)) != 0 {
			// Yellow, underlined "Warning:" prefix
			log(
				"\(csi)4;33mWarning:\(csi)0m \(message(items, separator: separator, terminator: terminator))",
				to: .standardError
			)
		} else {
			log("Warning: \(message(items, separator: separator, terminator: terminator))", to: .standardError)
		}
	}

	/// Prints to `stderr`; if connected to a terminal, prefixes "Error:" underlined in red.
	func error(_ items: Any..., error: Error? = nil, separator: String = " ", terminator: String = "\n") {
		errorCounter.wrappingIncrement(ordering: .relaxed)

		let terminator =
			if let error {
				"\(items.isEmpty ? "" : "\n")\(error)\(terminator)"
			} else {
				terminator
			}

		if isatty(fileno(stderr)) != 0 {
			// Red, underlined "Error:" prefix
			log(
				"\(csi)4;31mError:\(csi)0m \(message(items, separator: separator, terminator: terminator))",
				to: .standardError
			)
		} else {
			log("Error: \(message(items, separator: separator, terminator: terminator))", to: .standardError)
		}
	}

	func clearCurrentLine(fromStream stream: UnsafeMutablePointer<FILE>) {
		if isatty(fileno(stream)) != 0 {
			print(csi, "2K", csi, "0G", separator: "", terminator: "")
			fflush(stream)
		}
	}

	private func message(_ items: Any..., separator: String = " ", terminator: String = "\n") -> String {
		items.map { String(describing: $0) }.joined(separator: separator).appending(terminator)
	}
}

func run(_ expression: (Printer) throws -> Void) throws {
	let printer = Printer()
	do {
		try expression(printer)
	} catch {
		printer.error(error: error)
	}
	if printer.errorCount > 0 {
		throw ExitCode(1)
	}
}

func run(_ expression: (Printer) async throws -> Void) async throws {
	let printer = Printer()
	do {
		try await expression(printer)
	} catch {
		printer.error(error: error)
	}
	if printer.errorCount > 0 {
		throw ExitCode(1)
	}
}
