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
struct Printer {
	private let errorCounter = ManagedAtomic<UInt64>(0)

	var errorCount: UInt64 {
		errorCounter.load(ordering: .acquiring)
	}

	func resetErrorCount() { // periphery:ignore
		errorCounter.store(0, ordering: .releasing) // swiftlint:disable:previous unused_declaration
	}

	/// Prints to `stdout`.
	@_disfavoredOverload
	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		info(items, separator: separator, terminator: terminator)
	}

	/// Prints to `stdout`.
	func info(_ items: [Any], separator: String = " ", terminator: String = "\n") {
		print(items.map(String.init(describing:)), separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Prints to `stdout`, prefixed with "==> "; if connected to a terminal, the
	/// prefix is blue.
	@_disfavoredOverload
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
	@_disfavoredOverload
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
	@_disfavoredOverload
	func error(_ items: Any..., error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		self.error(items, error: error, separator: separator, terminator: terminator)
	}

	/// Prints to `stderr`, prefixed with "Error: "; if connected to a terminal,
	/// the prefix is red & underlined.
	func error(_ items: [Any], error: (any Error)? = nil, separator: String = " ", terminator: String = "\n") {
		errorCounter.wrappingIncrement(ordering: .relaxed)
		problem(items, prefix: errorPrefix, format: errorFormat, error: error, separator: separator, terminator: terminator)
	}

	func clearCurrentLine(of fileHandle: FileHandle) {
		if fileHandle.isTerminal {
			do {
				try fileHandle.write(contentsOf: Data("\(csi)2K\(csi)0G".utf8))
			} catch {
				// Do nothing
			}
		}
	}

	private func problem(
		_ items: [Any],
		prefix: String,
		format: String,
		error: (any Error)?,
		separator: String,
		terminator: String,
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
			to: .standardError,
		)
	}

	private func print(_ items: [String], separator: String, terminator: String, to fileHandle: FileHandle) {
		do {
			try fileHandle.write(contentsOf: Data(items.joined(separator: separator).appending(terminator).utf8))
		} catch {
			// Do nothing
		}
	}

	private func print(
		_ items: [Any],
		prefix: String,
		format: String,
		separator: String,
		terminator: String,
		to fileHandle: FileHandle,
	) { // swiftformat:disable indent
		let indent = """

			\(
				String( // swiftlint:disable:this indentation_width
					repeating: " ",
					count:
						(prefix.range(of: "\n", options: .backwards).map { .init(prefix[$0.upperBound...]) } ?? prefix).count + 1,
				)
			)
			"""

		let formattedPrefix = prefix.formatted(with: format, for: fileHandle) // swiftformat:enable indent
		print(
			items.first.map { item in
				["\(formattedPrefix) \(mas.indent(item, with: indent))"]
				+ items.dropFirst().map { mas.indent($0, with: indent) } // swiftformat:disable:this indent
			}
			?? [formattedPrefix], // swiftformat:disable:this indent
			separator: mas.indent(separator, with: indent),
			terminator: terminator,
			to: fileHandle,
		)
	}
}

extension String {
	func formatted(with format: Self, for fileHandle: FileHandle) -> Self {
		fileHandle.isTerminal ? "\(csi)\(format)m\(self)\(csi)0m" : self
	}
}

private func indent(_ item: Any, with indent: String) -> String {
	.init(describing: item).replacing(nonEmptyLineStartRegex, with: indent)
}

let errorPrefix = "Error:"
let errorFormat = "4;31"

/// Terminal Control Sequence Indicator.
private let csi = "\u{001B}["

private let nonEmptyLineStartRegex = /\n(?!\n)/
