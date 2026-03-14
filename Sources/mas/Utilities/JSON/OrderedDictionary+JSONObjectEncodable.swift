//
// OrderedDictionary+JSONObjectEncodable.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

public import JSONAST
public import JSONEncoding
public import OrderedCollections

extension OrderedDictionary: @retroactive JSONEncodable where Key: CustomStringConvertible, Value: JSONEncodable {}

extension OrderedDictionary: @retroactive JSONObjectEncodable where Key: CustomStringConvertible, Value: JSONEncodable {
	public func encode(to json: inout JSON.ObjectEncoder<JSON.Key>) {
		for (key, value) in self {
			json[JSON.Key(rawValue: String(describing: key))] = value
		}
	}
}
