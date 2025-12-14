//
// AppCatalog.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol for searching for, and for looking up, apps from the MAS catalog.
protocol AppCatalog {
	/// Looks up app details.
	///
	/// - Parameters:
	///   - appID: App ID.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     lookup apps.
	/// - Returns: A `CatalogApp` for the given `appID` if `appID` is valid.
	/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
	///   Some other `Error` if any other problem occurs.
	func lookup(appID: AppID, inRegion region: Region) async throws -> CatalogApp

	/// Searches for apps.
	///
	/// - Parameters:
	///   - searchTerm: Term for which to search.
	///   - region: The ISO 3166-1 alpha-2 region of the storefront in which to
	///     search for apps.
	/// - Returns: A `[CatalogApp]` matching `searchTerm`.
	/// - Throws: An `Error` if any problem occurs.
	func search(for searchTerm: String, inRegion region: Region) async throws -> [CatalogApp]
}

extension AppCatalog {
	/// Looks up app details.
	///
	/// - Parameter appID: App ID.
	/// - Returns: A `CatalogApp` for the given `appID` if `appID` is valid.
	/// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
	///   Some other `Error` if any other problem occurs.
	func lookup(appID: AppID) async throws -> CatalogApp {
		try await lookup(appID: appID, inRegion: appStoreRegion)
	}

	/// Searches for apps.
	///
	/// - Parameter searchTerm: Term for which to search.
	/// - Returns: A `[CatalogApp]` matching `searchTerm`.
	/// - Throws: An `Error` if any problem occurs.
	func search(for searchTerm: String) async throws -> [CatalogApp] {
		try await search(for: searchTerm, inRegion: appStoreRegion)
	}
}
