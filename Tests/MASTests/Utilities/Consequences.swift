//
// Consequences.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Foundation

struct Consequences<Value: Equatable>: Equatable {
	let value: Value?
	let error: Error?
	let stdout: String
	let stderr: String

	init(_ error: Error? = nil, _ stdout: String = "", _ stderr: String = "") where Value == NoValue {
		self.init(nil, error, stdout, stderr)
	}

	init(_ value: Value?, _ error: Error? = nil, _ stdout: String = "", _ stderr: String = "") {
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

enum NoValue: Equatable { // swiftlint:disable:this one_declaration_per_file
	// Empty
}

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: @autoclosure () throws -> Void
) -> Consequences<NoValue> {
	consequencesOf(streamEncoding: streamEncoding, try {
		try body()
		return nil as NoValue?
	}())
}

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: @autoclosure () async throws -> Void
) async -> Consequences<NoValue> {
	await consequencesOf(streamEncoding: streamEncoding, try await {
		try await body()
		return nil as NoValue?
	}())
}

func consequencesOf<Value: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @autoclosure () throws -> Value?
) -> Consequences<Value> {
	let outOriginalFD = fileno(stdout)
	let errOriginalFD = fileno(stderr)

	let outDuplicateFD = dup(outOriginalFD)
	defer {
		close(outDuplicateFD)
	}

	let errDuplicateFD = dup(errOriginalFD)
	defer {
		close(errDuplicateFD)
	}

	let outPipe = Pipe()
	let errPipe = Pipe()

	dup2(outPipe.fileHandleForWriting.fileDescriptor, outOriginalFD)
	dup2(errPipe.fileHandleForWriting.fileDescriptor, errOriginalFD)

	var value: Value?
	var thrownError: Error?
	do {
		defer {
			fflush(stdout)
			fflush(stderr)
			dup2(outDuplicateFD, outOriginalFD)
			dup2(errDuplicateFD, errOriginalFD)
			outPipe.fileHandleForWriting.closeFile()
			errPipe.fileHandleForWriting.closeFile()
		}

		value = try body()
	} catch {
		thrownError = error
	}

	return Consequences(
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}

func consequencesOf<Value: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @autoclosure () async throws -> Value?
) async -> Consequences<Value> {
	let outOriginalFD = fileno(stdout)
	let errOriginalFD = fileno(stderr)

	let outDuplicateFD = dup(outOriginalFD)
	defer {
		close(outDuplicateFD)
	}

	let errDuplicateFD = dup(errOriginalFD)
	defer {
		close(errDuplicateFD)
	}

	let outPipe = Pipe()
	let errPipe = Pipe()

	dup2(outPipe.fileHandleForWriting.fileDescriptor, outOriginalFD)
	dup2(errPipe.fileHandleForWriting.fileDescriptor, errOriginalFD)

	var value: Value?
	var thrownError: Error?
	do {
		defer {
			fflush(stdout)
			fflush(stderr)
			dup2(outDuplicateFD, outOriginalFD)
			dup2(errDuplicateFD, errOriginalFD)
			outPipe.fileHandleForWriting.closeFile()
			errPipe.fileHandleForWriting.closeFile()
		}

		value = try await body()
	} catch {
		thrownError = error
	}

	return Consequences(
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}
