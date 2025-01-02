//
//  SoftwareMapAppLibrary.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit
import ScriptingBridge

/// Utility for managing installed apps.
class SoftwareMapAppLibrary: AppLibrary {
    /// CommerceKit's singleton manager of installed software.
    private let softwareMap: SoftwareMap

    /// Array of installed software products.
    lazy var installedApps = softwareMap.allSoftwareProducts()
        .filter { product in
            product.bundlePath.starts(with: "/Applications/")
        }

    /// Internal initializer for providing a mock software map.
    /// - Parameter softwareMap: SoftwareMap to use
    init(softwareMap: SoftwareMap = CKSoftwareMap.shared()) {
        self.softwareMap = softwareMap
    }

    deinit {
        // do nothing
    }

    /// Uninstalls all apps located at any of the elements of `appPaths`.
    ///
    /// - Parameter appPaths: Paths to apps to be uninstalled.
    /// - Throws: Error if any problem occurs.
    func uninstallApps(atPaths appPaths: [String]) throws {
        try delete(pathsFromOwnerIDsByPath: try chown(paths: appPaths))
    }
}

private func getOwnerAndGroupOfItem(atPath path: String) throws -> (uid_t, gid_t) {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)
        guard
            let uid = attributes[.ownerAccountID] as? uid_t,
            let gid = attributes[.groupOwnerAccountID] as? gid_t
        else {
            throw MASError.runtimeError("Failed to determine running user's uid & gid")
        }
        return (uid, gid)
    }
}

private func chown(paths: [String]) throws -> [String: (uid_t, gid_t)] {
    guard let sudoUID = ProcessInfo.processInfo.sudoUID else {
        throw MASError.runtimeError("Failed to get original uid")
    }

    guard let sudoGID = ProcessInfo.processInfo.sudoGID else {
        throw MASError.runtimeError("Failed to get original gid")
    }

    let ownerIDsByPath = try paths.reduce(into: [String: (uid_t, gid_t)]()) { dict, path in
        dict[path] = try getOwnerAndGroupOfItem(atPath: path)
    }

    var chownedIDsByPath = [String: (uid_t, gid_t)]()
    for (path, ownerIDs) in ownerIDsByPath {
        guard chown(path, sudoUID, sudoGID) == 0 else {
            for (chownedPath, chownedIDs) in chownedIDsByPath
            where chown(chownedPath, chownedIDs.0, chownedIDs.1) != 0 {
                printError("Failed to revert ownership of '\(path)' back to uid \(chownedIDs.0) & gid \(chownedIDs.1)")
            }
            throw MASError.runtimeError("Failed to change ownership of '\(path)' to uid \(sudoUID) & gid \(sudoGID)")
        }

        chownedIDsByPath[path] = ownerIDs
    }

    return ownerIDsByPath
}

private func delete(pathsFromOwnerIDsByPath ownerIDsByPath: [String: (uid_t, gid_t)]) throws {
    guard let finder: FinderApplication = SBApplication(bundleIdentifier: "com.apple.finder") else {
        throw MASError.runtimeError("Failed to obtain Finder access: com.apple.finder does not exist")
    }

    guard let items = finder.items else {
        throw MASError.runtimeError("Failed to obtain Finder access: finder.items does not exist")
    }

    for (path, ownerIDs) in ownerIDsByPath {
        let object = items().object(atLocation: URL(fileURLWithPath: path))

        guard let item = object as? FinderItem else {
            throw MASError.runtimeError(
                """
                Failed to obtain Finder access: finder.items().object(atLocation: URL(fileURLWithPath: \
                \"\(path)\") is a '\(type(of: object))' that does not conform to 'FinderItem'
                """
            )
        }

        guard let delete = item.delete else {
            throw MASError.runtimeError("Failed to obtain Finder access: FinderItem.delete does not exist")
        }

        let uid = ownerIDs.0
        let gid = ownerIDs.1
        guard let deletedURLString = (delete() as FinderItem).URL else {
            throw MASError.runtimeError(
                """
                Failed to revert ownership of deleted '\(path)' back to uid \(uid) & gid \(gid): \
                delete result did not have a URL
                """
            )
        }

        guard let deletedURL = URL(string: deletedURLString) else {
            throw MASError.runtimeError(
                """
                Failed to revert ownership of deleted '\(path)' back to uid \(uid) & gid \(gid): \
                delete result URL is invalid: \(deletedURLString)
                """
            )
        }

        let deletedPath = deletedURL.path
        print("Deleted '\(path)' to '\(deletedPath)'")
        guard chown(deletedPath, uid, gid) == 0 else {
            throw MASError.runtimeError(
                "Failed to revert ownership of deleted '\(deletedPath)' back to uid \(uid) & gid \(gid)"
            )
        }
    }
}
