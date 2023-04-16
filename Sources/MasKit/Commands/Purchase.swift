//
//  Purchase.swift
//  mas-cli
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

import Commandant
import CommerceKit

public struct PurchaseCommand: CommandProtocol {
    public typealias Options = PurchaseOptions
    public let verb = "purchase"
    public let function = "Purchase and download free apps from the Mac App Store"

    private let appLibrary: AppLibrary

    /// Public initializer.
    public init() {
        self.init(appLibrary: MasAppLibrary())
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    init(appLibrary: AppLibrary = MasAppLibrary()) {
        self.appLibrary = appLibrary
    }

    /// Runs the command.
    public func run(_ options: Options) -> Result<Void, MASError> {
        if #available(macOS 10.15, *) {
            // Purchases are no longer possible as of Catalina.
            // https://github.com/mas-cli/mas/issues/289
	    printWarning("Purchases are no longer supported as of Catalina. (but may work)")
	    // return .failure(.notSupported)
        }

        // Try to download applications with given identifiers and collect results
        let appIds = options.appIds.filter { appId in
            if let product = appLibrary.installedApp(forId: appId) {
                printWarning("\(product.appName) has already been purchased.")
                return false
            }

            return true
        }

        do {
            try downloadAll(appIds, purchase: true).wait()
        } catch {
            return .failure(error as? MASError ?? .downloadFailed(error: error as NSError))
        }

        return .success(())
    }
}

public struct PurchaseOptions: OptionsProtocol {
    let appIds: [UInt64]

    public static func create(_ appIds: [Int]) -> PurchaseOptions {
        PurchaseOptions(appIds: appIds.map { UInt64($0) })
    }

    public static func evaluate(_ mode: CommandMode) -> Result<PurchaseOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(usage: "app ID(s) to install")
    }
}
