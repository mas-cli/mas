//
// Consequences.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Foundation

struct Consequences<Value> {
	let value: Value?
	let error: (any Error)?
	let stdout: String
	let stderr: String

	init(_ error: (any Error)? = nil, _ stdout: String = "", _ stderr: String = "") where Value == NoValue {
		self.init(nil, error, stdout, stderr)
	}

	init(_ value: Value?, _ error: (any Error)? = nil, _ stdout: String = "", _ stderr: String = "") {
		self.value = value
		self.error = error
		self.stdout = stdout
		self.stderr = stderr
	}
}

extension Consequences: Equatable where Value: Equatable { // swiftlint:disable:this file_types_order
	static func == (lhs: Self, rhs: Self) -> Bool {
		guard lhs.value == rhs.value, lhs.stdout == rhs.stdout, lhs.stderr == rhs.stderr else {
			return false
		}

		return switch (lhs.error, rhs.error) {
		case (nil, nil):
			true
		case let (lhsError?, rhsError?):
			(lhsError as NSError) == (rhsError as NSError)
		default:
			false
		}
	}
}

private struct StandardStreamCapture { // swiftlint:disable:this one_declaration_per_file
	private let encoding: String.Encoding
	private let outOriginalFD: Int32
	private let errOriginalFD: Int32
	private let outDuplicateFD: Int32
	private let errDuplicateFD: Int32
	private let outPipe: Pipe
	private let errPipe: Pipe

	init(encoding: String.Encoding) {
		self.encoding = encoding

		outOriginalFD = FileHandle.standardOutput.fileDescriptor
		errOriginalFD = FileHandle.standardError.fileDescriptor

		outDuplicateFD = dup(outOriginalFD)
		errDuplicateFD = dup(errOriginalFD)

		outPipe = Pipe()
		errPipe = Pipe()

		dup2(outPipe.fileHandleForWriting.fileDescriptor, outOriginalFD)
		dup2(errPipe.fileHandleForWriting.fileDescriptor, errOriginalFD)
	}

	func consequences(value _: Void, error: (any Error)? = nil) -> Consequences<NoValue> {
		let (stdout, stderr) = finishAndRead(encoding: encoding)
		return Consequences(nil as NoValue?, error, stdout, stderr)
	}

	func consequences<Value>(value: Value? = nil, error: (any Error)? = nil) -> Consequences<Value> {
		let (stdout, stderr) = finishAndRead(encoding: encoding)
		return Consequences(value, error, stdout, stderr)
	}

	private func finishAndRead(encoding: String.Encoding) -> (stdout: String, stderr: String) {
		unsafe fflush(stdout)
		unsafe fflush(stderr)
		dup2(outDuplicateFD, outOriginalFD)
		dup2(errDuplicateFD, errOriginalFD)
		try? outPipe.fileHandleForWriting.close()
		try? errPipe.fileHandleForWriting.close()

		close(outDuplicateFD)
		close(errDuplicateFD)

		return ( // swiftlint:disable:next force_try
			try! outPipe.fileHandleForReading.readToEnd().flatMap { String(data: $0, encoding: encoding) } ?? "",
			try! errPipe.fileHandleForReading.readToEnd().flatMap { String(data: $0, encoding: encoding) } ?? "",
		) // swiftlint:disable:previous force_try
	}
}

enum NoValue: Equatable { // swiftlint:disable:this one_declaration_per_file
	// Empty
}

func consequencesOf(encoding: String.Encoding = .utf8, _ body: @autoclosure () throws -> Void)
-> Consequences<NoValue> { // swiftformat:disable:this indent
	let capture = StandardStreamCapture(encoding: encoding)
	do {
		return capture.consequences(value: try body())
	} catch {
		return capture.consequences(error: error)
	}
}

func consequencesOf(encoding: String.Encoding = .utf8, _ body: @autoclosure () async throws -> Void)
async -> Consequences<NoValue> { // swiftformat:disable:this indent
	let capture = StandardStreamCapture(encoding: encoding)
	do {
		return capture.consequences(value: try await body())
	} catch {
		return capture.consequences(error: error)
	}
}

func consequencesOf<Value>(encoding: String.Encoding = .utf8, _ body: @autoclosure () throws -> Value?)
-> Consequences<Value> { // swiftformat:disable:this indent
	let capture = StandardStreamCapture(encoding: encoding)
	do {
		return capture.consequences(value: try body())
	} catch {
		return capture.consequences(error: error)
	}
}

func consequencesOf<Value>(encoding: String.Encoding = .utf8, _ body: @autoclosure () async throws -> Value?)
async -> Consequences<Value> { // swiftformat:disable:this indent
	let capture = StandardStreamCapture(encoding: encoding)
	do {
		return capture.consequences(value: try await body())
	} catch {
		return capture.consequences(error: error)
	}
}
