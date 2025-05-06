//
// Consequences.swift
// masTests
//
// Created by Ross Goldberg on 2024-12-29.
// Copyright © 2024 mas-cli. All rights reserved.
//

import Foundation

@testable internal import mas

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () throws -> Void
) -> (error: MASError?, stdout: String, stderr: String) {
	let consequences = consequences(streamEncoding: streamEncoding, expression)
	return (consequences.error, consequences.stdout, consequences.stderr)
}

func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () async throws -> Void
) async -> (error: MASError?, stdout: String, stderr: String) {
	let consequences = await consequences(streamEncoding: streamEncoding, expression)
	return (consequences.error, consequences.stdout, consequences.stderr)
}

func consequencesOf<T>(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () throws -> T
) -> (value: T?, error: MASError?, stdout: String, stderr: String) {
	consequences(streamEncoding: streamEncoding, expression)
}

func consequencesOf<T>(
	streamEncoding: String.Encoding = .utf8,
	_ expression: @autoclosure @escaping () async throws -> T
) async -> (value: T?, error: MASError?, stdout: String, stderr: String) {
	await consequences(streamEncoding: streamEncoding, expression)
}

// periphery:ignore
func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () throws -> Void
) -> (error: MASError?, stdout: String, stderr: String) {
	let consequences = consequences(streamEncoding: streamEncoding, body)
	return (consequences.error, consequences.stdout, consequences.stderr)
}

// periphery:ignore
func consequencesOf(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () async throws -> Void
) async -> (error: MASError?, stdout: String, stderr: String) {
	let consequences = await consequences(streamEncoding: streamEncoding, body)
	return (consequences.error, consequences.stdout, consequences.stderr)
}

// periphery:ignore
func consequencesOf<T>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () throws -> T
) -> (value: T?, error: MASError?, stdout: String, stderr: String) {
	consequences(streamEncoding: streamEncoding, body)
}

// periphery:ignore
func consequencesOf<T>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () async throws -> T
) async -> (value: T?, error: MASError?, stdout: String, stderr: String) {
	await consequences(streamEncoding: streamEncoding, body)
}

private func consequences<T>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () throws -> T
) -> (value: T?, error: MASError?, stdout: String, stderr: String) {
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

	var value: T?
	var thrownError: MASError?
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
	} catch let error as MASError {
		thrownError = error
	} catch {
		thrownError = MASError.failed(error: error as NSError)
	}

	return (
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}

private func consequences<T>(
	streamEncoding: String.Encoding = .utf8,
	_ body: @escaping () async throws -> T
) async -> (value: T?, error: MASError?, stdout: String, stderr: String) {
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

	var value: T?
	var thrownError: MASError?
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
	} catch let error as MASError {
		thrownError = error
	} catch {
		thrownError = MASError.failed(error: error as NSError)
	}

	return (
		value,
		thrownError,
		String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? "",
		String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: streamEncoding) ?? ""
	)
}
