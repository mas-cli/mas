//
// URL.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

private import AppKit

extension URL {
	func open() async throws {
		try await NSWorkspace.shared.open(self, configuration: NSWorkspace.OpenConfiguration())
	}
}
