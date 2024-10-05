//
//  MASError.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Foundation

public enum MASError: Error, Equatable {
    case notSupported

    case notSignedIn
    case signInFailed(error: NSError?)
    case alreadySignedIn

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
    public var description: String {
        switch self {
        case .notSignedIn:
            return "Not signed in"

        case .notSupported:
            return """
                This command is not supported on this macOS version due to changes in macOS. \
                For more information see: \
                https://github.com/mas-cli/mas#%EF%B8%8F-known-issues
                """

        case .signInFailed(let error):
            if let error {
                return "Sign in failed: \(error.localizedDescription)"
            } else {
                return "Sign in failed"
            }

        case .alreadySignedIn:
            return "Already signed in"

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
