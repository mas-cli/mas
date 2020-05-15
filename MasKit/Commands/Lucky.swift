//
//  Lucky.swift
//  mas-cli
//
//  Created by Pablo Varela on 05/11/17.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import CommerceKit

/// Command which installs the first search result. This is handy as many MAS titles
/// can be long with embedded keywords.
public struct LuckyCommand: CommandProtocol {
    public typealias Options = LuckyOptions
    public let verb = "lucky"
    public let function = "Install the first result from the Mac App Store"

    private let appLibrary: AppLibrary
    private let storeSearch: StoreSearch

    /// Public initializer.
    /// - Parameter storeSearch: Search manager.
    public init(storeSearch: StoreSearch = MasStoreSearch()) {
        self.init(appLibrary: MasAppLibrary(), storeSearch: storeSearch)
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    /// - Parameter storeSearch: Search manager.
    init(appLibrary: AppLibrary = MasAppLibrary(),
         storeSearch: StoreSearch = MasStoreSearch()) {
         self.appLibrary = appLibrary
         self.storeSearch = storeSearch
    }

    /// Runs the command.
    public func run(_ options: Options) -> Result<(), MASError> {
        var appId: Int?

        do {
            let results = try storeSearch.search(for: options.appName)
            guard let result = results.results.first else {
                print("No results found")
                return .failure(.noSearchResultsFound)
            }

            appId = result.trackId
        } catch {
            // Bubble up MASErrors
            if let error = error as? MASError {
                return .failure(error)
            }
            return .failure(.searchFailed)
        }

        guard let identifier = appId else { fatalError() }

        return install(UInt64(identifier), options: options)
    }

    /// Installs an app.
    ///
    /// - Parameters:
    ///   - appId: App identifier
    ///   - options: command opetions.
    /// - Returns: Result of the operation.
    fileprivate func install(_ appId: UInt64, options: Options) -> Result<(), MASError> {
        // Try to download applications with given identifiers and collect results
        let downloadResults = [appId].compactMap { (appId) -> MASError? in
            if let product = appLibrary.installedApp(forId: appId), !options.forceInstall {
                printWarning("\(product.appName) is already installed")
                return nil
            }

            return download(appId)
        }

        switch downloadResults.count {
        case 0:
            return .success(())
        case 1:
            return .failure(downloadResults[0])
        default:
            return .failure(.downloadFailed(error: nil))
        }
    }
}

public struct LuckyOptions: OptionsProtocol {
    let appName: String
    let forceInstall: Bool

    public static func create(_ appName: String) -> (_ forceInstall: Bool) -> LuckyOptions {
        return { forceInstall in
            LuckyOptions(appName: appName, forceInstall: forceInstall)
        }
    }

    public static func evaluate(_ mode: CommandMode) -> Result<LuckyOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(usage: "the app name to install")
            <*> mode <| Switch(flag: nil, key: "force", usage: "force reinstall")
    }
}
