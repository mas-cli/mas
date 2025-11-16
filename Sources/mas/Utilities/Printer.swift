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
///
/// Can only be initialized by the `run` global functions, which throw an
/// `ExitCode(1)` iff any errors were printed.
struct Printer {
	private let errorCounter = ManagedAtomic<UInt64>(0)

	fileprivate var errorCount: UInt64 { errorCounter.load(ordering: .acquiring) }

	fileprivate init() {
		// Do nothing
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

	/// Prints to `stdout`, prefixed with "==> "; if connected to a terminal, the prefix is blue.
	func notice(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		print(items, prefix: "==>", format: "1;34", separator: separator, terminator: terminator, to: .standardOutput)
	}

	/// Prints to `stderr`, prefixed with "Warning: "; if connected to a terminal,
	/// the prefix is yellow & underlined.
	func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		print(items, prefix: "Warning:", format: "4;33", separator: separator, terminator: terminator, to: .standardError)
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
			terminator: error.map { "\(items.isEmpty ? " " : "\n")\($0)\(terminator)" } ?? terminator,
			to: .standardError
		)
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

extension MAS {
	static func run(_ expression: (Printer) throws -> Void) throws {
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

	static func run(_ expression: (Printer) async throws -> Void) async throws {
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
}

/// Terminal Control Sequence Indicator.
private let csi = "\u{001B}["
