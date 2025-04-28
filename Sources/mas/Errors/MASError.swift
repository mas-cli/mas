//
//  MASError.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Foundation

enum MASError: Error, Equatable {
    case notSupported

    case failed(error: NSError?)

    case runtimeError(String)

    case notSignedIn
    case noPasswordProvided
    case signInFailed(error: NSError?)
    case alreadySignedIn(asAppleAccount: String)

    case purchaseFailed(error: NSError?)
    case downloadFailed(error: NSError?)
    case noDownloads
    case cancelled

    case searchFailed
    case noSearchResultsFound

    case unknownAppID(AppID)

    case noVendorWebsite

    case notInstalled(appID: AppID)
    case uninstallFailed(error: NSError?)
    case macOSUserMustBeRoot

    case noData
    case jsonParsing(data: Data)
}

extension MASError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notSignedIn:
            "Not signed in"
        case .noPasswordProvided:
            "No password provided"
        case .notSupported:
            """
            This command is not supported on this macOS version due to changes in macOS.
            See: https://github.com/mas-cli/mas#known-issues
            """
        case .failed(let error):
            if let error {
                "Failed: \(error.localizedDescription)"
            } else {
                "Failed"
            }
        case .runtimeError(let message):
            "Runtime Error: \(message)"
        case .signInFailed(let error):
            if let error {
                "Sign in failed: \(error.localizedDescription)"
            } else {
                "Sign in failed"
            }
        case .alreadySignedIn(let appleAccount):
            "Already signed in as \(appleAccount)"
        case .purchaseFailed(let error):
            if let error {
                "Download request failed: \(error.localizedDescription)"
            } else {
                "Download request failed"
            }
        case .downloadFailed(let error):
            if let error {
                "Download failed: \(error.localizedDescription)"
            } else {
                "Download failed"
            }
        case .noDownloads:
            "No downloads began"
        case .cancelled:
            "Download cancelled"
        case .searchFailed:
            "Search failed"
        case .noSearchResultsFound:
            "No apps found"
        case .unknownAppID(let appID):
            appID.unknownMessage
        case .noVendorWebsite:
            "App does not have a vendor website"
        case .notInstalled(let appID):
            "No apps installed with app ID \(appID)"
        case .uninstallFailed(let error):
            if let error {
                "Uninstall failed: \(error.localizedDescription)"
            } else {
                "Uninstall failed"
            }
        case .macOSUserMustBeRoot:
            "Apps installed from the Mac App Store require root permission to remove."
        case .noData:
            "Service did not return data"
        case .jsonParsing(let data):
            if let unparsable = String(data: data, encoding: .utf8) {
                "Unable to parse response as JSON:\n\(unparsable)"
            } else {
                "Unable to parse response as JSON"
            }
        }
    }
}
