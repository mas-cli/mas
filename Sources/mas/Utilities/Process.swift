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
	errorMessage: @autoclosure () -> String,
	runProcess run: (Process) throws -> Void = { try $0.run() },
) async throws -> (standardOutputString: String, standardErrorString: String) {
	let process = Process()
	process.executableURL = URL(filePath: executablePath, directoryHint: .notDirectory)
	process.arguments = args

	let standardOutputPipe = Pipe()
	let standardErrorPipe = Pipe()

	process.standardOutput = standardOutputPipe
	process.standardError = standardErrorPipe

	let standardOutputTask = Task(priority: .background) {
		try standardOutputPipe.readToEnd()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
	}
	let standardErrorTask = Task(priority: .background) {
		try standardErrorPipe.readToEnd()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
	}

	do {
		try run(process)
	} catch {
		throw MASError.error(errorMessage(), error: error)
	}
	process.waitUntilExit()

	let standardOutputString = try await standardOutputTask.value
	let standardErrorString = try await standardErrorTask.value

	guard process.terminationStatus == 0 else {
		throw MASError.error(
			"""
			\(errorMessage())
			Exit status: \(process.terminationStatus)\
			\(standardOutputString.ifNotEmptyPrepend("\n\nStandard output:\n"))\
			\(standardErrorString.ifNotEmptyPrepend("\n\nStandard error:\n"))
			""",
		)
	}

	return (standardOutputString, standardErrorString)
}

private extension String {
	func ifNotEmptyPrepend(_ prefix: String) -> Self {
		isEmpty ? self : prefix + self
	}
}
