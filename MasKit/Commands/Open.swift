//
//  Open.swift
//  mas-cli
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import Commandant

private let markerValue = "appstore"
private let masScheme = "macappstore"

/// Opens app page in MAS app. Uses the iTunes Lookup API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
public struct OpenCommand: CommandProtocol {
    public typealias Options = OpenOptions

    public let verb = "open"
    public let function = "Opens app page in AppStore.app"

    private let storeSearch: StoreSearch
    private var systemOpen: ExternalCommand

    /// Designated initializer.
    public init(storeSearch: StoreSearch = MasStoreSearch(),
                openCommand: ExternalCommand = OpenSystemCommand()) {
        self.storeSearch = storeSearch
        systemOpen = openCommand
    }

    /// Runs the command.
    public func run(_ options: OpenOptions) -> Result<(), MASError> {
        do {
            if options.appId == markerValue {
                // If no app ID is given, just open the MAS GUI app
                try systemOpen.run(arguments: masScheme + "://")
                return .success(())
            }

            guard let appId = Int(options.appId)
            else {
                print("Invalid app ID")
                return .failure(.noSearchResultsFound)
            }

            guard let result = try storeSearch.lookup(app: appId)
            else {
                print("No results found")
                return .failure(.noSearchResultsFound)
            }

            guard var url = URLComponents(string: result.trackViewUrl)
            else {
                return .failure(.searchFailed)
            }
            url.scheme = masScheme

            do {
                try systemOpen.run(arguments: url.string!)
            } catch {
                printError("Unable to launch open command")
                return .failure(.searchFailed)
            }
            if systemOpen.failed {
                let reason = systemOpen.process.terminationReason
                printError("Open failed: (\(reason)) \(systemOpen.stderr)")
                return .failure(.searchFailed)
            }
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

public struct OpenOptions: OptionsProtocol {
    var appId: String

    static func create(_ appId: String) -> OpenOptions {
        return OpenOptions(appId: appId)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<OpenOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(defaultValue: markerValue, usage: "the app ID")
    }
}
