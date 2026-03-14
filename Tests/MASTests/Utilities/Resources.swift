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

func decode<T: JSONDecodable>(
	_: T.Type = T.self, // swiftlint:disable:this function_default_parameter_at_end
	fromResource resource: String,
	encoding: String.Encoding = .utf8,
) throws -> T {
	guard let json = String(data: try Data(fromResource: resource), encoding: encoding) else {
		throw MASError.unparsableJSON()
	}

	return try T(json: JSON.Node(parsingFragment: json))
}
