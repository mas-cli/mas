//
// JSONOptionGroup.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Foundation

struct JSONOptionGroup: ParsableArguments {
	@Flag(name: .customLong("json"), help: "Output JSON")
	private var shouldOutputJSON = false

	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		var stat = stat()
		MAS.printer.info(
			items,
			separator: separator,
			terminator: terminator,
			to: unsafe shouldOutputJSON || fstat(3, &stat) != 0 || (stat.st_mode & S_IFMT) != S_IFIFO
			? .standardOutput // swiftformat:disable:this indent
			: FileHandle(fileDescriptor: 3),
		)
	}
}
