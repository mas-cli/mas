//
// OutputFormatOptionGroup.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Darwin
private import Foundation

struct OutputFormatOptionGroup: ParsableArguments {
	@Flag(name: .customLong("json"), help: "Output JSON")
	var shouldOutputJSON = false

	func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		var stat = stat()
		MAS.printer.info(
			items,
			separator: separator,
			terminator: terminator,
			to: unsafe shouldOutputJSON || fstat(3, &stat) != 0 || (stat.st_mode & S_IFMT) != S_IFIFO
			? .standardOutput // swiftformat:disable:this indent
			: .init(fileDescriptor: 3),
		)
	}
}
