//
// UnvaluedConsequences.swift
// masTests
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Foundation

struct UnvaluedConsequences: Equatable {
	let error: Error?
	let stdout: String
	let stderr: String

	init(_ error: Error? = nil, _ stdout: String = "", _ stderr: String = "") {
		self.error = error
		self.stdout = stdout
		self.stderr = stderr
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		guard lhs.stdout == rhs.stdout, lhs.stderr == rhs.stderr else {
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

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure () throws -> Void
) -> UnvaluedConsequences {
	consequences(streamEncoding: streamEncoding, expression)
}

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure () async throws -> Void
) async -> UnvaluedConsequences {
	await consequences(streamEncoding: streamEncoding, expression)
}

// periphery:ignore
func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: () throws -> Void
) -> UnvaluedConsequences {
	consequences(streamEncoding: streamEncoding, body)
}

// periphery:ignore
func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: () async throws -> Void
) async -> UnvaluedConsequences {
	await consequences(streamEncoding: streamEncoding, body)
}

private func consequences(
	streamEncoding: String.Encoding = .utf8,
	_ body: () throws -> Void
) -> UnvaluedConsequences {
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

		try body()
	} catch {
		thrownError = error
	}

	return UnvaluedConsequences(
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}

private func consequences(
	streamEncoding: String.Encoding = .utf8,
	_ body: () async throws -> Void
) async -> UnvaluedConsequences {
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

		try await body()
	} catch {
		thrownError = error
	}

	return UnvaluedConsequences(
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}
