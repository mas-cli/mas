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
}

extension String? {
	var quoted: String {
		map(\.quoted) ?? "unknown"
	}
}
