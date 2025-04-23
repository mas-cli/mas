//
//  SpotlightSoftwareMap.swift
//  mas
//
//  Created by Ross Goldberg on 2025-04-09.
//  Copyright © 2025 mas-cli. All rights reserved.
//

import Foundation

class SpotlightSoftwareMap: SoftwareMap {
    private var observer: NSObjectProtocol?

    deinit {
        // do nothing
    }

    @MainActor
    func installedApps() async -> [InstalledApp] {
        defer {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        let query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")

        do {
            query.searchScopes =
                try FileManager.default
                .contentsOfDirectory(at: URL(fileURLWithPath: "/Volumes"), includingPropertiesForKeys: [])
                .compactMap { url in
                    let applicationsURL = url.appendingPathComponent("Applications")
                    return applicationsURL.hasDirectoryPath
                        ? applicationsURL
                        : nil
                }
        } catch {
            query.searchScopes = ["/Applications"]
        }

        return await withCheckedContinuation { continuation in
            observer = NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: nil
            ) { notification in
                guard let query = notification.object as? NSMetadataQuery else {
                    continuation.resume(returning: [])
                    return
                }

                query.stop()

                continuation.resume(
                    returning: query.results.compactMap { result in
                        if let item = result as? NSMetadataItem {
                            // swift-format-ignore
                            SimpleInstalledApp(
                                appID:
                                    item.value(forAttribute: "kMDItemAppStoreAdamID") as? AppID ?? 0,
                                appName:
                                    (item.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
                                    .removingSuffix(".app"),
                                bundleIdentifier:
                                    item.value(forAttribute: NSMetadataItemCFBundleIdentifierKey) as? String ?? "",
                                bundlePath:
                                    item.value(forAttribute: NSMetadataItemPathKey) as? String ?? "",
                                bundleVersion:
                                    item.value(forAttribute: NSMetadataItemVersionKey) as? String ?? ""
                            )
                        } else {
                            nil
                        }
                    }
                )
            }

            query.start()
        }
    }
}

private extension String {
    func removingSuffix(_ suffix: Self) -> Self {
        hasSuffix(suffix)
            ? Self(dropLast(suffix.count))
            : self
    }
}
