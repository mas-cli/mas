//
//  Home.swift
//  mas-cli
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import Commandant

/// Opens app page on MAS Preview. Uses the iTunes Lookup API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
public struct HomeCommand: CommandProtocol {
    public typealias Options = HomeOptions

    public let verb = "home"
    public let function = "Opens MAS Preview app page in a browser"

    private let storeSearch: StoreSearch
    private var openCommand: ExternalCommand

    public init() {
        self.init(
            storeSearch: MasStoreSearch(),
            openCommand: OpenSystemCommand()
        )
    }

    /// Designated initializer.
    init(
        storeSearch: StoreSearch = MasStoreSearch(),
        openCommand: ExternalCommand = OpenSystemCommand()
    ) {
        self.storeSearch = storeSearch
        self.openCommand = openCommand
    }

    /// Runs the command.
    public func run(_ options: HomeOptions) -> Result<Void, MASError> {
        do {
            guard let result = try storeSearch.lookup(app: options.appId).wait() else {
                return .failure(.noSearchResultsFound)
            }

            do {
                try openCommand.run(arguments: result.trackViewUrl)
            } catch {
                printError("Unable to launch open command")
                return .failure(.searchFailed)
            }
            if openCommand.failed {
                let reason = openCommand.process.terminationReason
                printError("Open failed: (\(reason)) \(openCommand.stderr)")
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

public struct HomeOptions: OptionsProtocol {
    let appId: UInt64

    static func create(_ appId: Int) -> HomeOptions {
        HomeOptions(appId: UInt64(appId))
    }

    public static func evaluate(_ mode: CommandMode) -> Result<HomeOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(usage: "ID of app to show on MAS Preview")
    }
}
