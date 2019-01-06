//
//  Search.swift
//  mas-cli
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import Result

struct ResultKeys {
    static let ResultCount = "resultCount"
    static let Results = "results"
    static let TrackName = "trackName"
    static let TrackId = "trackId"
    static let Version = "version"
    static let Price = "price"
}

/// Search the Mac App Store using the iTunes Search API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
public struct SearchCommand: CommandProtocol {
    public typealias Options = SearchOptions
    public let verb = "search"
    public let function = "Search for apps from the Mac App Store"

    private let networkSession: NetworkSession

    public init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }

    public func run(_ options: Options) -> Result<(), MASError> {
        guard let searchURLString = searchURLString(options.appName),
              let searchJson = networkSession.requestSynchronousJSONWithURLString(searchURLString) as? [String: Any] else {
            return .failure(.searchFailed)
        }

        guard let resultCount = searchJson[ResultKeys.ResultCount] as? Int, resultCount > 0,
              let results = searchJson[ResultKeys.Results] as? [[String: Any]] else {
            print("No results found")
            return .failure(.noSearchResultsFound)
        }

        // find out longest appName for formatting
        var appNameMaxLength = 0
        for result in results {
            if let appName = result[ResultKeys.TrackName] as? String {
                if appName.count > appNameMaxLength {
                    appNameMaxLength = appName.count
                }
            }
        }
        if appNameMaxLength > 50 {
            appNameMaxLength = 50
        }

        for result in results {
            if let appName = result[ResultKeys.TrackName] as? String,
                let appVersion = result[ResultKeys.Version] as? String,
                let appId = result[ResultKeys.TrackId] as? Int,
                let appPrice = result[ResultKeys.Price] as? Double {
                
                // add empty spaces to app name that every app name has the same length
                let countedAppName = String((appName + String(repeating: " ", count: appNameMaxLength)).prefix(appNameMaxLength))
                
                if options.price {
                    print(String(format:"%12d  %@  $%5.2f  (%@)", appId, countedAppName, appPrice, appVersion))
                } else {
                    print(String(format:"%12d  %@ (%@)", appId, countedAppName, appVersion))
                }
            }
        }

        return .success(())
    }

    
    /// Builds a URL to search the MAS for an app
    ///
    /// - Parameter appName: Name of the app to find.
    /// - Returns: String URL for app search or nil if the app name could not be encoded.
    func searchURLString(_ appName: String) -> String? {
        guard let urlEncodedAppName = appName.URLEncodedString else { return nil }
        
        return "https://itunes.apple.com/search?entity=macSoftware&term=\(urlEncodedAppName)&attribute=allTrackTerm"
    }
}

public struct SearchOptions: OptionsProtocol {
    let appName: String
    let price: Bool

    public static func create(_ appName: String) -> (_ price: Bool) -> SearchOptions {
        return { price in
            SearchOptions(appName: appName, price: price)
        }
    }

    public static func evaluate(_ m: CommandMode) -> Result<SearchOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app name to search")
            <*> m <| Option(key: "price", defaultValue: false, usage: "Show price of found apps")
    }
}
