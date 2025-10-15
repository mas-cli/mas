//
// SpotlightInstalledApps.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
private import ObjectiveC

private extension String {
	func removingSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix)
		? Self(dropLast(suffix.count)) // swiftformat:disable:this indent
		: self
	}
}

@MainActor
var installedApps: [InstalledApp] {
	get async throws {
		var observer: (any NSObjectProtocol)?
		defer {
			if let observer {
				NotificationCenter.default.removeObserver(observer)
			}
		}

		let query = NSMetadataQuery()
		query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")
		query.searchScopes = UserDefaults(suiteName: "com.apple.appstored")?
		.dictionary(forKey: "PreferredVolume")?["name"] // swiftformat:disable indent
		.map { [applicationsFolder, "/Volumes/\($0)\(applicationsFolder)"] }
		?? [applicationsFolder]

		return try await withCheckedThrowingContinuation { continuation in // swiftformat:enable indent
			observer = NotificationCenter.default.addObserver(
				forName: .NSMetadataQueryDidFinishGathering,
				object: query,
				queue: nil
			) { notification in
				guard let query = notification.object as? NSMetadataQuery else {
					continuation.resume(
						throwing: MASError.runtimeError(
							"Notification Center returned a \(type(of: notification.object)) instead of a NSMetadataQuery"
						)
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
								version: item.value(forAttribute: NSMetadataItemVersionKey) as? String ?? ""
							)
						}
					}
					.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending } // swiftformat:enable indent
				)
			}

			query.start()
		}
	}
}

private var applicationsFolder: String { "/Applications" }
