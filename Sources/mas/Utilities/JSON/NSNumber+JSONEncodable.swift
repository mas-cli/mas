//
// NSNumber+JSONEncodable.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import CoreFoundation
public import Foundation
public import JSONAST
public import JSONEncoding
private import ObjectiveC

extension NSNumber: @retroactive JSONEncodable { // swiftlint:disable:this legacy_objc_type
	public func encode(to json: inout JSON) {
		guard self !== kCFBooleanTrue else {
			json.utf8 += "true".utf8
			return
		}
		guard self !== kCFBooleanFalse else {
			json.utf8 += "false".utf8
			return
		}

		json.utf8 += description.utf8
	}
}
