//
//  Info.swift
//  mas-cli
//
//  Created by Denis Lebedev on 21/10/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import Foundation

/// Displays app details. Uses the iTunes Lookup API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
public struct InfoCommand: CommandProtocol {
    public let verb = "info"
    public let function = "Display app information from the Mac App Store"

    private let storeSearch: StoreSearch

    /// Designated initializer.
    public init(storeSearch: StoreSearch = MasStoreSearch()) {
        self.storeSearch = storeSearch
    }

    /// Runs the command.
    public func run(_ options: InfoOptions) -> Result<(), MASError> {
        do {
            guard let result = try storeSearch.lookup(app: options.appId) else {
                print("No results found")
                return .failure(.noSearchResultsFound)
            }

            print(AppInfoFormatter.format(app: result))
        } catch {
            // Bubble up MASErrors
            if let error = error as? MASError {
                return .failure(error)
            }
            return .failure(.searchFailed)
        }

        return .success(())
    }
}

public struct InfoOptions: OptionsProtocol {
    let appId: Int

    static func create(_ appId: Int) -> InfoOptions {
        return InfoOptions(appId: appId)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<InfoOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(usage: "ID of app to show info")
    }
}
