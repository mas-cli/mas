//
//  AppLibraryMock.swift
//  masTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import mas

class AppLibraryMock: AppLibrary {
    var installedApps: [SoftwareProduct] = []

    func uninstallApps(atPaths appPaths: [String]) throws {
        // Special case for testing where we pretend the trash command failed
        if appPaths.contains("/dev/null") {
            throw MASError.uninstallFailed(error: nil)
        }
    }
}

/// Members not part of the AppLibrary protocol that are only for test state management.
extension AppLibraryMock {
    /// Clears out the list of installed apps.
    func reset() {
        installedApps = []
    }
}
