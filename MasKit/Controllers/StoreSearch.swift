//
//  StoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol for searching the MAS catalog.
public protocol StoreSearch {
    func lookup(app appId: Int) throws -> SearchResult?
    func search(for appName: String) throws -> SearchResultList
}

// MARK: - Common methods
extension StoreSearch {
    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: MAS app identifier.
    /// - Returns: URL for the search service or nil if appName can't be encoded.
    public func searchURL(for appName: String) -> URL? {
        guard let urlString = searchURLString(forApp: appName) else { return nil }
        return URL(string: urlString)
    }

    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: Name of app to find.
    /// - Returns: String URL for the search service or nil if appName can't be encoded.
    func searchURLString(forApp appName: String) -> String? {
        if let urlEncodedAppName = appName.URLEncodedString {
            return "https://itunes.apple.com/search?media=software&entity=macSoftware&term=\(urlEncodedAppName)"
        }
        return nil
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appId can't be encoded.
    public func lookupURL(forApp appId: Int) -> URL? {
        guard let urlString = lookupURLString(forApp: appId) else { return nil }
        return URL(string: urlString)
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: String URL for the lookup service.
    func lookupURLString(forApp appId: Int) -> String? {
        return "https://itunes.apple.com/lookup?id=\(appId)"
    }
}
