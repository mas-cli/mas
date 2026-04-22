//
// AppStoreAction.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Darwin
private import OrderedCollections

enum AppStoreAction: String {
	case get
	case install
	case update

	var performed: String {
		switch self {
		case .get:
			"got"
		case .install:
			"installed"
		case .update:
			"updated"
		}
	}

	var performing: String {
		switch self {
		case .get:
			"getting"
		case .install:
			"installing"
		case .update:
			"updating"
		}
	}

	func apps(withAppIDs appIDs: [AppID], force: Bool, installedApps: [InstalledApp]) async throws {
		try await apps(withADAMIDs: await appIDs.catalogApps.map(\.adamID), force: force, installedApps: installedApps)
	}

	func apps(withADAMIDs adamIDs: [ADAMID], force: Bool, installedApps: [InstalledApp]) async throws {
		try await apps(
			withADAMIDs: adamIDs.filter { adamID in
				if !force, let installedApp = installedApps.first(where: { $0.adamID == adamID }) {
					MAS.printer.warning("Already ", performed, " ", installedApp.name, " (", adamID, ")", separator: "")
					return false
				}

				return true
			},
		)
	}

	func apps(withADAMIDs adamIDs: [ADAMID]) async throws {
		guard !adamIDs.isEmpty else {
			return
		}

		let adamIDOrderedSet = OrderedSet(adamIDs)
		guard getuid() == 0 else {
			try sudo(MAS._commandName, args: [rawValue, "--force"] + adamIDOrderedSet.map(String.init(_:)))
			return
		}

		await adamIDOrderedSet.forEach(attemptTo: "\(self) app for ADAM ID") { adamID in
			try await app(withADAMID: adamID) { _, _ in false }
		}
	}
}

typealias AppStore = AppStoreAction
