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
    func allSoftwareProducts() async -> [SoftwareProduct] {
        defer {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        let query = NSMetadataQuery()
        query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")
        query.searchScopes = ["/Applications"]

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
                        if let result = result as? NSMetadataItem {
                            // swift-format-ignore
                            SimpleSoftwareProduct(
                                appID:
                                    result.value(forAttribute: "kMDItemAppStoreAdamID") as? AppID ?? 0,
                                appName:
                                    (result.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
                                    .removeSuffix(".app"),
                                bundleIdentifier:
                                    result.value(forAttribute: kMDItemCFBundleIdentifier as String) as? String ?? "",
                                bundlePath:
                                    result.value(forAttribute: kMDItemPath as String) as? String ?? "",
                                bundleVersion:
                                    result.value(forAttribute: kMDItemVersion as String) as? String ?? ""
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
    func removeSuffix(_ suffix: String) -> String {
        hasSuffix(suffix)
            ? String(dropLast(suffix.count))
            : self
    }
}
