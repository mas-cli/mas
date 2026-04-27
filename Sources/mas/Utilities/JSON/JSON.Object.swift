//
// JSON.Object.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import JSONAST
internal import JSONDecoding

extension JSON.Object {
	subscript(nodeKey key: JSON.Key) -> JSON.Node? {
		fields.first { $0.key == key }?.value
	}

	subscript(key: JSON.Key) -> JSON.OptionalDecoder<JSON.Key> {
		.init(key: key, value: self[nodeKey: key])
	} // periphery:ignore

	subscript(key: JSON.Key) -> JSON.FieldDecoder<JSON.Key>? {
		self[nodeKey: key].map { .init(key: key, value: $0) }
	}
}
