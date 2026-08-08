//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

enum MASError: Error {
	case error(String, cause: (any Error)? = nil, separatorWhenCause: String = ":\n", separatorWhenNoCause: String = "")
	case invalidJSON(String)
	case invalidURL(String)
	case noCatalogAppsFound(for: String)
	case unknownAppID(AppID)

	static func error(
		_ message: String,
		cause: String?,
		separatorWhenCause: String = ":\n",
		separatorWhenNoCause: String = "",
	) -> Self {
		.error(
			message,
			cause: cause.map { Self.error($0) },
			separatorWhenCause: separatorWhenCause,
			separatorWhenNoCause: separatorWhenNoCause,
		)
	}
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case let .error(message, cause, separatorWhenCause, separatorWhenNoCause):
			"\(message)\(cause.map { "\(separatorWhenCause)\($0)" } ?? separatorWhenNoCause)"
		case let .invalidJSON(string):
			"Failed to parse JSON:\n\(string)"
		case let .invalidURL(string):
			"Failed to parse URL: \(string)"
		case let .noCatalogAppsFound(searchTerm):
			"Failed to find apps in the App Store for search term: \(searchTerm)"
		case let .unknownAppID(appID):
			"Failed to find app in the App Store with \(appID)"
		}
	}
}
