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

    case notSignedIn
    case noPasswordProvided
    case signInFailed(error: NSError?)
    case alreadySignedIn(asAccountId: String)

    case purchaseFailed(error: NSError?)
    case downloadFailed(error: NSError?)
    case noDownloads
    case cancelled

    case searchFailed
    case noSearchResultsFound
    case noVendorWebsite

    case notInstalled
    case uninstallFailed

    case noData
    case jsonParsing(data: Data?)
}

// MARK: - CustomStringConvertible
extension MASError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notSignedIn:
            return "Not signed in"
        case .noPasswordProvided:
            return "No password provided"
        case .notSupported:
            return """
                This command is not supported on this macOS version due to changes in macOS. \
                For more information see: \
                https://github.com/mas-cli/mas#known-issues
                """
        case .failed(let error):
            if let error {
                return "Failed: \(error.localizedDescription)"
            } else {
                return "Failed"
            }
        case .signInFailed(let error):
            if let error {
                return "Sign in failed: \(error.localizedDescription)"
            } else {
                return "Sign in failed"
            }
        case .alreadySignedIn(let accountId):
            return "Already signed in as \(accountId)"
        case .purchaseFailed(let error):
            if let error {
                return "Download request failed: \(error.localizedDescription)"
            } else {
                return "Download request failed"
            }
        case .downloadFailed(let error):
            if let error {
                return "Download failed: \(error.localizedDescription)"
            } else {
                return "Download failed"
            }
        case .noDownloads:
            return "No downloads began"
        case .cancelled:
            return "Download cancelled"
        case .searchFailed:
            return "Search failed"
        case .noSearchResultsFound:
            return "No results found"
        case .noVendorWebsite:
            return "App does not have a vendor website"
        case .notInstalled:
            return "Not installed"
        case .uninstallFailed:
            return "Uninstall failed"
        case .noData:
            return "Service did not return data"
        case .jsonParsing(let data):
            if let data {
                if let unparsable = String(data: data, encoding: .utf8) {
                    return "Unable to parse response as JSON: \n\(unparsable)"
                } else {
                    return "Received defective response"
                }
            } else {
                return "Received empty response"
            }
        }
    }
}
