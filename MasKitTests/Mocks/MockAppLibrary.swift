//
//  MockAppLibrary.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

class MockAppLibrary: AppLibrary {
    func installedApp(appId: UInt64) -> SoftwareProduct? {
        return nil
    }
}
