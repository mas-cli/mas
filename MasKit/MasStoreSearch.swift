//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
public class MasStoreSearch : StoreSearch {
    public init() {}

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: A string URL for the lookup service or nil if the appId can't be encoded.
    public func lookupURLString(forApp appId: String) -> String? {
        if let urlEncodedAppId = appId.URLEncodedString {
            return "https://itunes.apple.com/lookup?id=\(urlEncodedAppId)"
        }
        return nil
    }
}
