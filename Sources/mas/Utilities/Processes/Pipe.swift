//
// Pipe.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Foundation

extension Pipe {
	func readToEnd(encoding: String.Encoding = .utf8) throws -> String? {
		try fileHandleForReading.readToEnd().flatMap { .init(data: $0, encoding: encoding) }
	}
}
