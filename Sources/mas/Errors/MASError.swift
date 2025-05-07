//
// MASError.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import Foundation

enum MASError: Error, Equatable {
	case notSupported

	case runtimeError(String)

	case purchaseFailed(error: NSError?)
	case downloadFailed(error: NSError?)
	case noDownloads
	case cancelled

	case searchFailed
	case noSearchResultsFound

	case unknownAppID(AppID)

	case noVendorWebsite

	case notInstalled(appIDs: [AppID])
	case macOSUserMustBeRoot

	case jsonParsing(data: Data)

	case urlParsing(String)
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case .notSupported:
			"""
			This command is not supported on this macOS version due to changes in macOS.
			See: https://github.com/mas-cli/mas#known-issues
			"""
		case let .runtimeError(message):
			"Runtime Error: \(message)"
		case let .purchaseFailed(error):
			if let error {
				"Download request failed: \(error.localizedDescription)"
			} else {
				"Download request failed"
			}
		case let .downloadFailed(error):
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
		case let .unknownAppID(appID):
			appID.unknownMessage
		case .noVendorWebsite:
			"App does not have a vendor website"
		case let .notInstalled(appIDs):
			"No apps installed with app ID \(appIDs.map { String($0) }.joined(separator: ", "))"
		case .macOSUserMustBeRoot:
			"Apps installed from the Mac App Store require root permission to remove"
		case let .jsonParsing(data):
			if let unparsable = String(data: data, encoding: .utf8) {
				"Unable to parse response as JSON:\n\(unparsable)"
			} else {
				"Unable to parse response as JSON"
			}
		case let .urlParsing(string):
			"Unable to parse URL from: \(string)"
		}
	}
}
