//
// AnyJSONEncodable.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import Foundation
internal import JSONAST
internal import JSONEncoding

struct AnyJSONEncodable: JSONEncodable {
	private let encodeBase: (inout JSON) -> Void

	init(_ base: some JSONEncodable) {
		encodeBase = { json in
			base.encode(to: &json)
		}
	}

	init?(from value: Any?) {
		guard let value else {
			return nil
		}

		self =
			switch value {
			case let jsonEncodable as any JSONEncodable:
				Self(jsonEncodable)
			case let array as [Any?]:
				Self(array.map(Self.init(from:)))
			case let data as Data:
				Self(data)
			case let date as Date:
				Self(date)
			default:
				Self(String(describing: value))
			}
	}

	func encode(to json: inout JSON) {
		encodeBase(&json)
	}
}
