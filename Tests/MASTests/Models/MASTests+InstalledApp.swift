//
// MASTests+InstalledApp.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `uses App Store name for installed app`() async throws {
		let catalogApp = try decode(CatalogApp.self, fromResource: "things-lookup")
		let actual = try await consequencesOf(
			await Environment.$current.withValue(environment { _ in catalogApp }) {
				await [InstalledApp(for: installedThingsAttributes())].withCatalogNames.first?.name
			},
		)
		let expected = Consequences("Things That Go Bump")
		#expect(actual == expected)
	}

	@Test
	func `falls back to approximated name of installed app unknown to App Store`() async throws {
		let actual = try await consequencesOf(
			await Environment.$current.withValue(environment { throw MASError.unknownAppID($0) }) {
				await [InstalledApp(for: installedThingsAttributes())].withCatalogNames.first?.name
			},
		)
		let expected = Consequences("Things That Go Bmup")
		#expect(actual == expected)
	}

	@Test
	func `keeps approximated name of installed app without an ADAM ID`() async throws {
		let catalogApp = try decode(CatalogApp.self, fromResource: "things-lookup")
		let actual = try await consequencesOf(
			await Environment.$current.withValue(environment { _ in catalogApp }) {
				await [InstalledApp(for: installedThingsAttributes(adamID: 0))].withCatalogNames.first?.name
			},
		)
		let expected = Consequences("Things That Go Bmup")
		#expect(actual == expected)
	}
}

private func environment(
	lookingUpAppFromAppID lookupAppFromAppID: @escaping @Sendable (AppID) async throws -> CatalogApp,
) -> Environment {
	.init(lookupAppFromAppID: lookupAppFromAppID)
}

private func installedThingsAttributes(adamID: ADAMID = 1_472_954_003) -> [String: Any] {
	[
		"kMDItemAppStoreAdamID": adamID,
		NSMetadataItemCFBundleIdentifierKey: "uikitformac.com.tinybop.thingamabops",
		// Deliberately misspelled to distinguish the approximated name from the App Store name
		"_kMDItemDisplayNameWithExtensions": "Things That Go Bmup.app",
		NSMetadataItemPathKey: "/Applications/Things That Go Bmup.app",
		NSMetadataItemVersionKey: "1.3.0",
	]
}
