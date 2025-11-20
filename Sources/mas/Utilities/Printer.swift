//
// Printer.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Atomics
private import Darwin
internal import Foundation

/// Prints to `stdout` and `stderr` with ANSI color codes when connected to a
/// terminal.
struct Printer {
	private let errorCounter = ManagedAtomic<UInt64>(0)

	var errorCount: UInt64 {
		errorCounter.load(ordering: .acquiring)
	}

	func resetErrorCount() { // periphery:ignore
		errorCounter.store(0, ordering: .releasing) // swiftlint:disable:previous unused_declaration
	}

	/// Prints to `stdout`.
	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		print(items.map(String.init(describing:)), separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Clears current line from `stdout`, then prints to `stdout`, then flushes
	/// `stdout`.
	func ephemeral(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		clearCurrentLine(of: .standardOutput)
		print(items.map(String.init(describing:)), separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Clears current line of `stdout`.
	func terminateEphemeral() {
		clearCurrentLine(of: .standardOutput)
	}

	/// Prints to `stdout`, prefixed with "==> "; if connected to a terminal, the
	/// prefix is blue.
	func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		print(items, prefix: "==>", format: "1;34", separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Prints to `stderr`, prefixed with "Warning: "; if connected to a terminal,
	/// the prefix is yellow & underlined.
	func warning(_ items: Any..., error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		print(
			items,
			prefix: "Warning:",
			format: "4;33",
			separator: separator,
			terminator: errorTerminator(items, error: error, terminator: terminator),
			to: .standardError
		)
	}

	/// Prints to `stderr`, prefixed with "Error: "; if connected to a terminal,
	/// the prefix is red & underlined.
	func error(_ items: Any..., error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		errorCounter.wrappingIncrement(ordering: .relaxed)
		print(
			items,
			prefix: "Error:",
			format: "4;31",
			separator: separator,
			terminator: errorTerminator(items, error: error, terminator: terminator),
			to: .standardError
		)
	}

	private func errorTerminator(_ items: Any..., error: (any Error)?, terminator: String) -> String {
		error.map { error in
			let errorDescription = String(describing: error)
			return "\(errorDescription.isEmpty ? "" : items.isEmpty ? " " : "\n")\(errorDescription)\(terminator)"
		}
		?? terminator // swiftformat:disable:this indent
	}

	private func print(_ items: [String], separator: String, terminator: String, to fileHandle: FileHandle) {
		fileHandle.write(Data(items.joined(separator: separator).appending(terminator).utf8))
	}

	private func print( // swiftlint:disable:this function_parameter_count
		_ items: [Any],
		prefix: String,
		format: String,
		separator: String,
		terminator: String,
		to fileHandle: FileHandle
	) {
		let formattedPrefix = isatty(fileHandle.fileDescriptor) != 0 ? "\(csi)\(format)m\(prefix)\(csi)0m" : "\(prefix)"
		print(
			items.first.map { ["\(formattedPrefix) \($0)"] + items.dropFirst().map(String.init(describing:)) }
			?? [formattedPrefix], // swiftformat:disable:this indent
			separator: separator,
			terminator: terminator,
			to: fileHandle
		)
	}

	private func clearCurrentLine(of fileHandle: FileHandle) {
		if isatty(fileHandle.fileDescriptor) != 0 {
			fileHandle.write(Data("\(csi)2K\(csi)0G".utf8))
		}
	}
}

/// Terminal Control Sequence Indicator.
private let csi = "\u{001B}["
