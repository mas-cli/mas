//
// Printer.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Atomics
internal import Foundation

/// Prints to `stdout` and `stderr` with ANSI color codes when connected to a
/// terminal.
struct Printer: Sendable {
	private let errorCounter = ManagedAtomic<UInt64>(0)

	var errorCount: UInt64 {
		errorCounter.load(ordering: .acquiring)
	}

	func resetErrorCount() { // periphery:ignore
		errorCounter.store(0, ordering: .releasing) // swiftlint:disable:previous unused_declaration
	}

	/// Prints to `stdout`.
	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		info(items, separator: separator, terminator: terminator)
	}

	/// Prints to `stdout`.
	func info(_ items: [Any], separator: String = " ", terminator: String = "\n") {
		print(items.map(String.init(describing:)), separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Prints to `stdout`, prefixed with "==> "; if connected to a terminal, the
	/// prefix is blue.
	func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		notice(items, separator: separator, terminator: terminator)
	}

	/// Prints to `stdout`, prefixed with "==> "; if connected to a terminal, the
	/// prefix is blue.
	func notice(_ items: [Any], separator: String = " ", terminator: String = "\n") {
		print(items, prefix: "==>", format: "1;34", separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Prints to `stderr`, prefixed with "Warning: "; if connected to a terminal,
	/// the prefix is yellow & underlined.
	func warning(_ items: Any..., error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		warning(items, error: error, separator: separator, terminator: terminator)
	}

	/// Prints to `stderr`, prefixed with "Warning: "; if connected to a terminal,
	/// the prefix is yellow & underlined.
	func warning(_ items: [Any], error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		problem(items, prefix: "Warning:", format: "4;33", error: error, separator: separator, terminator: terminator)
	}

	/// Prints to `stderr`, prefixed with "Error: "; if connected to a terminal,
	/// the prefix is red & underlined.
	func error(_ items: Any..., error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		self.error(items, error: error, separator: separator, terminator: terminator)
	}

	/// Prints to `stderr`, prefixed with "Error: "; if connected to a terminal,
	/// the prefix is red & underlined.
	func error(_ items: [Any], error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		errorCounter.wrappingIncrement(ordering: .relaxed)
		problem(items, prefix: "Error:", format: "4;31", error: error, separator: separator, terminator: terminator)
	}

	func clearCurrentLine(of fileHandle: FileHandle) {
		if fileHandle.isTerminal {
			fileHandle.write(Data("\(csi)2K\(csi)0G".utf8))
		}
	}

	private func problem(
		_ items: [Any],
		prefix: String,
		format: String,
		error: (any Error)?,
		separator: String,
		terminator: String
	) {
		guard !items.isEmpty || (error != nil && !(error is ExitCode)) else {
			return
		}

		print(
			items,
			prefix: prefix,
			format: format,
			separator: separator,
			terminator: error.map { error in
				let errorDescription = String(describing: error)
				return "\(errorDescription.isEmpty ? "" : items.isEmpty ? " " : "\n")\(errorDescription)\(terminator)"
			}
			?? terminator, // swiftformat:disable:this indent
			to: .standardError
		)
	}

	private func print(_ items: [String], separator: String, terminator: String, to fileHandle: FileHandle) {
		fileHandle.write(Data(items.joined(separator: separator).appending(terminator).utf8))
	}

	private func print(
		_ items: [Any],
		prefix: String,
		format: String,
		separator: String,
		terminator: String,
		to fileHandle: FileHandle
	) {
		let formattedPrefix = fileHandle.isTerminal ? "\(csi)\(format)m\(prefix)\(csi)0m" : prefix
		print(
			items.first.map { ["\(formattedPrefix) \($0)"] + items.dropFirst().map(String.init(describing:)) }
			?? [formattedPrefix], // swiftformat:disable:this indent
			separator: separator,
			terminator: terminator,
			to: fileHandle
		)
	}
}

/// Terminal Control Sequence Indicator.
private let csi = "\u{001B}["
