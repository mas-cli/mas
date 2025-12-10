//
// InstallAppCommand.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

protocol InstallAppCommand: AsyncParsableCommand, Sendable {
	var appStoreAction: AppStoreAction { get }
	var forceOptionGroup: ForceOptionGroup { get }
	var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup { get }
}

extension InstallAppCommand {
	func run() async throws {
		try await run(installedApps: try await installedApps, appCatalog: ITunesSearchAppCatalog())
	}

	private func run(installedApps: [InstalledApp], appCatalog: some AppCatalog) async throws {
		try await run(
			installedApps: installedApps,
			adamIDs: await requiredAppIDsOptionGroup.appIDs.lookupCatalogApps(from: appCatalog).map(\.adamID)
		)
	}

	private func run(installedApps: [InstalledApp], adamIDs: [ADAMID]) async throws {
		try await appStoreAction.apps(withADAMIDs: adamIDs, force: forceOptionGroup.force, installedApps: installedApps)
	}
}
