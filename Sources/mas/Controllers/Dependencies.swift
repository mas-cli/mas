//
// Dependencies.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

struct Dependencies {
	@TaskLocal
	static var current = Self()

	let lookupAppFromAppID: @Sendable (AppID) async throws -> CatalogApp

	init(lookupAppFromAppID: @escaping @Sendable (AppID) async throws -> CatalogApp = lookup(appID:)) {
		self.lookupAppFromAppID = lookupAppFromAppID
	}
}
