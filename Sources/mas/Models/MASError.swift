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
			cause: cause.map { Self.error($0) }, // swiftformat:disable:this redundantStaticSelf
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
			"Invalid JSON:\n\(string)"
		case let .invalidURL(string):
			"Invalid URL: \(string)"
		case let .noCatalogAppsFound(searchTerm):
			"No apps found in the App Store for search term: \(searchTerm)"
		case let .unknownAppID(appID):
			"No apps found in the App Store for \(appID)"
		}
	}
}
