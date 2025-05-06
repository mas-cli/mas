//
// URL.swift
// mas
//
// Created by Ross Goldberg on 2024-10-28.
// Copyright © 2024 mas-cli. All rights reserved.
//

private import AppKit

extension URL {
	func open() async throws {
		try await NSWorkspace.shared.open(self, configuration: NSWorkspace.OpenConfiguration())
	}
}
