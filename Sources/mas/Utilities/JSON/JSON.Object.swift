//
// JSON.Object.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import JSONAST
internal import JSONDecoding

extension JSON.Object {
	subscript(key: JSON.Key) -> JSON.OptionalDecoder<JSON.Key> {
		.init(key: key, value: fields.first { $0.key == key }?.value)
	} // periphery:ignore

	subscript(key: JSON.Key) -> JSON.FieldDecoder<JSON.Key>? {
		(fields.first { $0.key == key }?.value).map { .init(key: key, value: $0) }
	}
}
