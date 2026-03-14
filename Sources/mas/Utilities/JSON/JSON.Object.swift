//
// JSON.Object.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import JSONAST
internal import JSONDecoding

extension JSON.Object {
	// periphery:ignore
	subscript(key: JSON.Key) -> JSON.OptionalDecoder<JSON.Key> {
		JSON.OptionalDecoder(key: key, value: fields.first { $0.key == key }?.value)
	}

	subscript(key: JSON.Key) -> JSON.FieldDecoder<JSON.Key>? {
		(fields.first { $0.key == key }?.value).map { JSON.FieldDecoder(key: key, value: $0) }
	}
}
