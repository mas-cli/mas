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
    public func run(_ options: Options) -> Result<(), MASError> {
        // Try to download applications with given identifiers and collect results
        let downloadResults = options.appIds.compactMap { (appId) -> MASError? in
            if let product = appLibrary.installedApp(forId: appId) {
                printWarning("\(product.appName) has already been purchased.")
                return nil
            }

            return download(appId, purchase: true)
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

public struct PurchaseOptions: OptionsProtocol {
    let appIds: [UInt64]

    public static func create(_ appIds: [Int]) -> PurchaseOptions {
        return PurchaseOptions(appIds: appIds.map { UInt64($0) })
    }

    public static func evaluate(_ mode: CommandMode) -> Result<PurchaseOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(usage: "app ID(s) to install")
    }
}
