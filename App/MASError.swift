//
//  Error.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Foundation

enum MASError: Error, CustomStringConvertible {
    case notSignedIn
    case signInDisabled
    case signInFailed(error: NSError?)
    case alreadySignedIn

    case purchaseFailed(error: NSError?)
    case downloadFailed(error: NSError?)
    case noDownloads
    case cancelled

    case searchFailed
    case noSearchResultsFound

    var description: String {
        switch self {
        case .notSignedIn:
            return "Not signed in"

        case .signInDisabled:
            return "The 'signin' command has been disabled on this macOS version. " +
                "Please sign into the Mac App Store app manually." +
                "\nFor more info see: " +
                "https://github.com/mas-cli/mas/issues/164"

        case .signInFailed(let error):
            if let error = error {
                return "Sign in failed: \(error.localizedDescription)"
            } else {
                return "Sign in failed"
            }

        case .alreadySignedIn:
            return "Already signed in"

        case .purchaseFailed(let error):
            if let error = error {
                return "Download request failed: \(error.localizedDescription)"
            } else {
                return "Download request failed"
            }

        case .downloadFailed(let error):
            if let error = error {
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
        }
    }
}
