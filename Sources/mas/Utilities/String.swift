//
// String.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation

extension String {
	var quoted: String {
		"'\(replacingOccurrences(of: "'", with: "\\'"))'"
	}

	func removingSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix) ? Self(dropLast(suffix.count)) : self
	}
}
