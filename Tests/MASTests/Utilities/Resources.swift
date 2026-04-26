//
// Resources.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import Foundation
private import JSONAST
internal import JSONDecoding
private import JSONParsing
@testable private import mas

// swiftlint:disable:next function_default_parameter_at_end
func decode<T: JSONDecodable>(_: T.Type = T.self, fromResource resource: String) throws -> T {
	try unsafe Data(fromResource: resource).withUnsafeBytes { bufferPointer in
		try .init(json: .init(parsing: unsafe RawSpan(_unsafeBytes: unsafe bufferPointer)))
	}
}
