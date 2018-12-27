//
//  MasAppLibrary.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

/// Utility for managing installed apps.
public class MasAppLibrary: AppLibrary {
    /// CommerceKit's singleton manager of installed software.
    private let softwareMap = CKSoftwareMap.shared()

    public init() {}

    /// Finds an app by ID from the set of installed apps
    ///
    /// - Parameter appId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    public func installedApp(appId: UInt64) -> SoftwareProduct? {
        let appId = NSNumber(value: appId)
        return softwareMap.allProducts()?.first { $0.itemIdentifier == appId }
    }
}
