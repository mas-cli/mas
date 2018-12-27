//
//  MockAppLibrary.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

class MockAppLibrary: AppLibrary {
    var apps = [SoftwareProduct]()

    func installedApp(appId: UInt64) -> SoftwareProduct? {
        return apps.first { $0.itemIdentifier == NSNumber(value: appId) }
    }

    func uninstallApp(app: SoftwareProduct) throws {
        if !apps.contains(where: { (product) -> Bool in
            return app.itemIdentifier == product.itemIdentifier
        }) { throw MASError.notInstalled }

        // Special case for testing where we pretend the trash command failed
        if app.bundlePath == "/dev/null" {
            throw MASError.uninstallFailed
        }

        // Success is the default, watch out for false positives!
    }
}
