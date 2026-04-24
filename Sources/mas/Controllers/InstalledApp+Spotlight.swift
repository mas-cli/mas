//
// InstalledApp+Spotlight.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Atomics
private import Foundation
private import ObjectiveC

private extension URL {
	var installedAppURLs: [URL] {
		FileManager.default
			.enumerator(at: self, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
			.map { enumerator in
				enumerator.compactMap { item in
					guard
						let url = item as? URL,
						(try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true,
						url.pathExtension == "app"
					else {
						return URL?.none
					}

					enumerator.skipDescendants()
					return try? url.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory)
						.resourceValues(forKeys: [.fileSizeKey])
						.fileSize
						.flatMap { $0 > 0 ? url : nil }
				}
			}
			?? .init()
	}
}

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
	query.predicate = .init(format: metadataQuery)
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

			let installedApps = query.results
				.compactMap { result in
					(result as? NSMetadataItem).map { item in
						InstalledApp(
							adamID: item.value(forAttribute: "kMDItemAppStoreAdamID") as? ADAMID ?? 0,
							bundleID: .init(describing: item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) ?? ""),
							name: .init(describing: item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") ?? "")
								.removingSuffix(".app"),
							path: .init(describing: item.value(forAttribute: NSMetadataItemPathKey) ?? ""),
							version: .init(describing: item.value(forAttribute: NSMetadataItemVersionKey) ?? ""),
						)
					}
				}
				.sorted(using: KeyPathComparator(\.name, comparator: .localizedStandard))

			if !["1", "true", "yes"].contains(ProcessInfo.processInfo.environment["MAS_NO_AUTO_INDEX"]?.lowercased()) {
				let installedAppPathSet = Set(installedApps.map(\.path))
				for installedAppURL in applicationsFolderURLs.flatMap(\.installedAppURLs)
				where !installedAppPathSet.contains(installedAppURL.filePath) { // swiftformat:disable:this indent
					MAS.printer.warning(
						"Found a likely App Store app that is not indexed in Spotlight in ",
						installedAppURL.filePath,
						"""


						Indexing now; will likely complete sometime after mas exits

						Disable auto-indexing via: export MAS_NO_AUTO_INDEX=1
						""",
						separator: "",
					)
					Task {
						do {
							_ = try await run(
								"/usr/bin/mdimport",
								installedAppURL.filePath,
								errorMessage: "Failed to index the Spotlight data for \(installedAppURL.filePath)",
							)
						} catch {
							MAS.printer.error(error: error)
						}
					}
				}
			}

			continuation.resume(returning: installedApps)
		}

		query.start()
	}
}
