//
// Date+JSONEncodable.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

public import Foundation
public import JSONAST
public import JSONEncoding

extension Date: @retroactive JSONEncodable {
	public func encode(to json: inout JSON) {
		json += JSON.Literal(formatted(.iso8601))
	}
}
