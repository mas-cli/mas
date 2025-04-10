// swift-format-ignore-file
//
//  SpotlightSoftwareMap.swift
//  mas
//
//  Created by Ross Goldberg on 2025-04-09.
//  Copyright © 2025 mas-cli. All rights reserved.
//

import Foundation

struct SpotlightSoftwareMap: SoftwareMap {
    func allSoftwareProducts() async -> [SoftwareProduct] {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let query = NSMetadataQuery()
                query.predicate = NSPredicate(format: "kMDItemAppStoreAdamID LIKE '*'")
                query.searchScopes = ["/Applications"]

                var observer: NSObjectProtocol?
                observer = NotificationCenter.default.addObserver(
                    forName: Notification.Name.NSMetadataQueryDidFinishGathering,
                    object: query,
                    queue: .main
                ) { [weak observer] _ in
                    query.stop()
                    if let observer {
                        NotificationCenter.default.removeObserver(observer)
                    }

                    continuation.resume(
                        returning: query.results.compactMap { result in
                            guard let result = result as? NSMetadataItem else {
                                return nil
                            }

                            return SimpleSoftwareProduct(
                                appName:
                                    (result.value(forAttribute: "_kMDItemDisplayNameWithExtensions") as? String ?? "")
                                    .removeSuffix(".app"),
                                bundleIdentifier:
                                    result.value(forAttribute: kMDItemCFBundleIdentifier as String) as? String ?? "",
                                bundlePath:
                                    result.value(forAttribute: kMDItemPath as String) as? String ?? "",
                                bundleVersion:
                                    result.value(forAttribute: kMDItemVersion as String) as? String ?? "",
                                itemIdentifier:
                                    // swiftlint:disable:next legacy_objc_type
                                    result.value(forAttribute: "kMDItemAppStoreAdamID") as? NSNumber ?? 0
                            )
                        }
                    )
                }

                query.start()
            }
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
