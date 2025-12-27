//
// Process.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Foundation
private import ObjectiveC

func run(
	_ executablePath: String,
	_ args: String...,
	runProcess run: (Process) throws -> Void = { try $0.run() },
	errorMessage: @autoclosure () -> String
) async throws -> (standardOutputText: String, standardErrorText: String) {
	let process = Process()
	process.executableURL = URL(fileURLWithPath: executablePath, isDirectory: false)
	process.arguments = args

	let standardOutputPipe = Pipe()
	let standardErrorPipe = Pipe()

	process.standardOutput = standardOutputPipe
	process.standardError = standardErrorPipe

	let standardOutputTask = Task.detached(priority: .background) {
		standardOutputPipe.fileHandleForReading.readDataToEndOfFile()
	}
	let standardErrorTask = Task.detached(priority: .background) {
		standardErrorPipe.fileHandleForReading.readDataToEndOfFile()
	}

	do {
		try run(process)
	} catch {
		throw MASError.error(errorMessage(), error: error)
	}
	process.waitUntilExit()

	let standardOutputText =
		String(data: await standardOutputTask.value, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
	let standardErrorText =
		String(data: await standardErrorTask.value, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

	guard process.terminationStatus == 0 else {
		throw MASError.error(
			"""
			\(errorMessage())
			Exit status: \(process.terminationStatus)\
			\(standardOutputText.ifNotEmptyPrepend("\n\nStandard output:\n"))\
			\(standardErrorText.ifNotEmptyPrepend("\n\nStandard error:\n"))
			"""
		)
	}

	return (standardOutputText, standardErrorText)
}

private extension String {
	func ifNotEmptyPrepend(_ prefix: String) -> Self {
		isEmpty ? self : prefix + self
	}
}
