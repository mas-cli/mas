//
// ValuedConsequences.swift
// masTests
//
// Created by Ross Goldberg on 2024-12-29.
// Copyright © 2024 mas-cli. All rights reserved.
//

import Foundation

struct ValuedConsequences<E: Equatable>: Equatable {
	let value: E?
	let error: Error?
	let stdout: String
	let stderr: String

	init(_ value: E? = nil, _ error: Error? = nil, _ stdout: String = "", _ stderr: String = "") {
		self.value = value
		self.error = error
		self.stdout = stdout
		self.stderr = stderr
	}

	static func == (lhs: ValuedConsequences<E>, rhs: ValuedConsequences<E>) -> Bool {
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

func consequencesOf<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () throws -> E
) -> ValuedConsequences<E> {
	consequences(streamEncoding: streamEncoding, expression)
}

func consequencesOf<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () async throws -> E
) async -> ValuedConsequences<E> {
	await consequences(streamEncoding: streamEncoding, expression)
}

// periphery:ignore
func consequencesOf<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () throws -> E
) -> ValuedConsequences<E> {
	consequences(streamEncoding: streamEncoding, body)
}

// periphery:ignore
func consequencesOf<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () async throws -> E
) async -> ValuedConsequences<E> {
	await consequences(streamEncoding: streamEncoding, body)
}

private func consequences<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () throws -> E
) -> ValuedConsequences<E> {
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

	var value: E?
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

	return ValuedConsequences(
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}

private func consequences<E: Equatable>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () async throws -> E
) async -> ValuedConsequences<E> {
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

	var value: E?
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

	return ValuedConsequences(
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}
