//
// String.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

extension String {
	var quoted: String {
		"'\(replacing("'", with: "\\'"))'"
	}

	func removingSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix) ? Self(dropLast(suffix.count)) : self
	}
}
