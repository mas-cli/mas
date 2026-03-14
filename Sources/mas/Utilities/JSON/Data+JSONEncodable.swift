//
// Data+JSONEncodable.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

public import Foundation
public import JSONAST
public import JSONEncoding

extension Data: @retroactive JSONEncodable {
	public func encode(to json: inout JSON) {
		json += JSON.Literal(
			isEmpty
			? "" // swiftformat:disable:this indent
			: {
				var hex = "0x"
				hex.reserveCapacity(2 + count * 2)
				return reduce(into: hex) { hex, byte in
					let byteHex = String(byte, radix: 16)
					if byteHex.count < 2 {
						hex += "0"
					}
					hex += byteHex
				}
			}(),
		)
	}
}
