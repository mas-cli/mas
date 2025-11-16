//
// URL.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import AppKit
private import Foundation
private import ObjectiveC

extension URL {
	func open(configuration: NSWorkspace.OpenConfiguration = NSWorkspace.OpenConfiguration()) async throws {
		try await NSWorkspace.shared.open(self, configuration: configuration)
	}
}
