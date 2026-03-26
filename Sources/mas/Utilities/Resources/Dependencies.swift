//
// Dependencies.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import Foundation

struct Dependencies {
	@TaskLocal
	static var current = Self()

	let dataFrom: @Sendable (URL) async throws -> (Data, URLResponse)
	let lookupAppFromAppID: @Sendable (AppID) async throws -> CatalogApp
	let searchForAppsMatchingSearchTerm: @Sendable (String) async throws -> [CatalogApp]

	init(
		dataFrom: @escaping @Sendable (URL) async throws -> (Data, URLResponse)
		= URLSession(configuration: .ephemeral).data(from:), // swiftformat:disable:this indent
		lookupAppFromAppID: @escaping @Sendable (AppID) async throws -> CatalogApp = lookup(appID:),
		searchForAppsMatchingSearchTerm: @escaping @Sendable (String) async throws -> [CatalogApp] = search(for:),
	) {
		self.dataFrom = dataFrom
		self.lookupAppFromAppID = lookupAppFromAppID
		self.searchForAppsMatchingSearchTerm = searchForAppsMatchingSearchTerm
	}
}
