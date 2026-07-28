//
// Subprocess.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Foundation
internal import Subprocess

func run<Encoding: Unicode.Encoding>(
	_ executable: Executable,
	_ args: String...,
	platformOptions: PlatformOptions = .init(),
	encoding: Encoding.Type = UTF8.self,
	maxCaptureByteCount: Int = 1024 * 1024,
	errorMessage: @autoclosure () -> String,
) async throws -> (outString: String, errString: String) {
	let executionResult = try await run(
		executable,
		arguments: .init(args),
		platformOptions: platformOptions,
		output: .string(limit: maxCaptureByteCount, encoding: encoding),
		error: .string(limit: maxCaptureByteCount, encoding: encoding),
	)
	let outString = executionResult.standardOutput?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
	let errString = executionResult.standardError?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
	guard executionResult.terminationStatus.isSuccess else {
		throw MASError.error(
			"""
			\(errorMessage())
			Exit status: \(executionResult.terminationStatus)\
			\(outString.ifNotEmptyPrepend("\n\nStandard output:\n"))\
			\(errString.ifNotEmptyPrepend("\n\nStandard error:\n"))
			""",
		)
	}

	return (outString, errString)
}
