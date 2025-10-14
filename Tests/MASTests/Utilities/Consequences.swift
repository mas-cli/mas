//
// Consequences.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Foundation

struct Consequences<Value: Equatable>: Equatable {
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

private struct StdStreamCapture { // swiftlint:disable:this one_declaration_per_file
	let outOriginalFD: Int32
	let errOriginalFD: Int32
	let outDuplicateFD: Int32
	let errDuplicateFD: Int32
	let outPipe: Pipe
	let errPipe: Pipe

	init() {
		outOriginalFD = FileHandle.standardOutput.fileDescriptor
		errOriginalFD = FileHandle.standardError.fileDescriptor

		outDuplicateFD = dup(outOriginalFD)
		errDuplicateFD = dup(errOriginalFD)

		outPipe = Pipe()
		errPipe = Pipe()

		dup2(outPipe.fileHandleForWriting.fileDescriptor, outOriginalFD)
		dup2(errPipe.fileHandleForWriting.fileDescriptor, errOriginalFD)
	}

	func finishAndRead(encoding: String.Encoding) -> (stdout: String, stderr: String) {
		fflush(stdout)
		fflush(stderr)
		dup2(outDuplicateFD, outOriginalFD)
		dup2(errDuplicateFD, errOriginalFD)
		outPipe.fileHandleForWriting.closeFile()
		errPipe.fileHandleForWriting.closeFile()

		close(outDuplicateFD)
		close(errDuplicateFD)

		return (
			String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: encoding) ?? "",
			String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: encoding) ?? ""
		)
	}
}

enum NoValue: Equatable { // swiftlint:disable:this one_declaration_per_file
	// Empty
}

func consequencesOf(
	encoding: String.Encoding = .utf8,
	_ body: @autoclosure () throws -> Void
) -> Consequences<NoValue> {
	let capture = StdStreamCapture()
	var thrownError: (any Error)?
	do {
		try body()
	} catch {
		thrownError = error
	}
	let (stdout, stderr) = capture.finishAndRead(encoding: encoding)
	return Consequences(thrownError, stdout, stderr)
}

func consequencesOf(
	encoding: String.Encoding = .utf8,
	_ body: @autoclosure () async throws -> Void
) async -> Consequences<NoValue> {
	let capture = StdStreamCapture()
	var thrownError: (any Error)?
	do {
		try await body()
	} catch {
		thrownError = error
	}
	let (stdout, stderr) = capture.finishAndRead(encoding: encoding)
	return Consequences(thrownError, stdout, stderr)
}

func consequencesOf<Value: Equatable>(
	encoding: String.Encoding = .utf8,
	_ body: @autoclosure () throws -> Value?
) -> Consequences<Value> {
	let capture = StdStreamCapture()
	var value: Value?
	var thrownError: (any Error)?
	do {
		value = try body()
	} catch {
		thrownError = error
	}
	let (stdout, stderr) = capture.finishAndRead(encoding: encoding)
	return Consequences(value, thrownError, stdout, stderr)
}

func consequencesOf<Value: Equatable>(
	encoding: String.Encoding = .utf8,
	_ body: @autoclosure () async throws -> Value?
) async -> Consequences<Value> {
	let capture = StdStreamCapture()
	var value: Value?
	var thrownError: (any Error)?
	do {
		value = try await body()
	} catch {
		thrownError = error
	}
	let (stdout, stderr) = capture.finishAndRead(encoding: encoding)
	return Consequences(value, thrownError, stdout, stderr)
}
