//
// MASError.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import Foundation

enum MASError: Error, Equatable {
	case cancelled
	case downloadFailed(error: NSError)
	case jsonParsing(data: Data)
	case macOSUserMustBeRoot
	case noDownloads
	case noSearchResultsFound
	case noVendorWebsite
	case notInstalled(appIDs: [AppID])
	case notSupported
	case purchaseFailed(error: NSError)
	case runtimeError(String)
	case searchFailed(error: NSError)
	case unknownAppID(AppID)
	case urlParsing(String)

	init(downloadFailedError: Error) {
		self = (downloadFailedError as? Self) ?? .downloadFailed(error: downloadFailedError as NSError)
	}

	init(purchaseFailedError: Error) {
		self = (purchaseFailedError as? Self) ?? .purchaseFailed(error: purchaseFailedError as NSError)
	}

	init(searchFailedError: Error) {
		self = (searchFailedError as? Self) ?? .searchFailed(error: searchFailedError as NSError)
	}
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case .cancelled:
			"Download cancelled"
		case let .downloadFailed(error):
			"Download failed: \(error.localizedDescription)"
		case let .jsonParsing(data):
			if let unparsable = String(data: data, encoding: .utf8) {
				"Unable to parse response as JSON:\n\(unparsable)"
			} else {
				"Unable to parse response as JSON"
			}
		case .macOSUserMustBeRoot:
			"Apps installed from the Mac App Store require root permission to remove"
		case .noDownloads:
			"No downloads began"
		case .noSearchResultsFound:
			"No apps found"
		case .noVendorWebsite:
			"App does not have a vendor website"
		case let .notInstalled(appIDs):
			"No apps installed with app ID \(appIDs.map { String($0) }.joined(separator: ", "))"
		case .notSupported:
			"""
			This command is not supported on this macOS version due to changes in macOS
			See: https://github.com/mas-cli/mas#known-issues
			"""
		case let .purchaseFailed(error):
			"Download request failed: \(error.localizedDescription)"
		case let .runtimeError(message):
			"Runtime error: \(message)"
		case let .searchFailed(error):
			"Search failed: \(error.localizedDescription)"
		case let .unknownAppID(appID):
			"App ID \(appID) not found in Mac App Store"
		case let .urlParsing(string):
			"Unable to parse URL from: \(string)"
		}
	}
}
