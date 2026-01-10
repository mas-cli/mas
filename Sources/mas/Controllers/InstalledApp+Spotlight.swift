//
// InstalledApp+Spotlight.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Atomics
private import Foundation
private import ObjectiveC

var installedApps: [InstalledApp] {
	get async throws {
		try await mas.installedApps(matching: "kMDItemAppStoreAdamID LIKE '*'")
	}
}

func installedApps(withADAMID adamID: ADAMID) async throws -> [InstalledApp] {
	try await installedApps(matching: "kMDItemAppStoreAdamID = \(adamID)")
}

@MainActor
func installedApps(matching metadataQuery: String) async throws -> [InstalledApp] {
	var observer = (any NSObjectProtocol)?.none
	defer {
		if let observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	let query = NSMetadataQuery()
	query.predicate = NSPredicate(format: metadataQuery)
	query.searchScopes = applicationsFolderURLs

	return try await withCheckedThrowingContinuation { continuation in
		let alreadyResumed = ManagedAtomic(false)
		observer = NotificationCenter.default.addObserver(
			forName: .NSMetadataQueryDidFinishGathering,
			object: query,
			queue: nil,
		) { notification in
			guard !alreadyResumed.exchange(true, ordering: .acquiringAndReleasing) else {
				return
			}
			guard let query = notification.object as? NSMetadataQuery else {
				continuation.resume(
					throwing: MASError.error(
						"Notification Center returned a \(type(of: notification.object)) instead of a NSMetadataQuery",
					),
				)
				return
			}

			query.stop()

			continuation.resume(
				returning: query.results
				.compactMap { result in // swiftformat:disable indent
					(result as? NSMetadataItem).map { item in
						InstalledApp(
							adamID: item.value(forAttribute: "kMDItemAppStoreAdamID") as? ADAMID ?? 0,
							bundleID: item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String ?? "",
							name: (item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
							.removingSuffix(".app"),
							path: item.value(forAttribute: NSMetadataItemPathKey) as? String ?? "",
							version: item.value(forAttribute: NSMetadataItemVersionKey) as? String ?? "",
						)
					}
				}
				.sorted(using: KeyPathComparator(\.name, comparator: .localizedStandard)), // swiftformat:enable indent
			)
		}

		query.start()
	}
}
