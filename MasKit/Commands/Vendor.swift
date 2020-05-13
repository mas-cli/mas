//
//  Vendor.swift
//  mas-cli
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import Commandant

/// Opens vendor's app page in a browser. Uses the iTunes Lookup API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
public struct VendorCommand: CommandProtocol {
    public typealias Options = VendorOptions

    public let verb = "vendor"
    public let function = "Opens vendor's app page in a browser"

    private let storeSearch: StoreSearch
    private var openCommand: ExternalCommand

    /// Designated initializer.
    public init(storeSearch: StoreSearch = MasStoreSearch(),
                openCommand: ExternalCommand = OpenSystemCommand()) {
        self.storeSearch = storeSearch
        self.openCommand = openCommand
    }

    /// Runs the command.
    public func run(_ options: VendorOptions) -> Result<(), MASError> {
        do {
            guard let result = try storeSearch.lookup(app: options.appId)
            else {
                print("No results found")
                return .failure(.noSearchResultsFound)
            }

            guard let vendorWebsite = result.sellerUrl
            else { throw MASError.noVendorWebsite }

            do {
                try openCommand.run(arguments: vendorWebsite)
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

public struct VendorOptions: OptionsProtocol {
    let appId: Int

    static func create(_ appId: Int) -> VendorOptions {
        return VendorOptions(appId: appId)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<VendorOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(usage: "the app ID to show the vendor's website")
    }
}
