//
//  Purchase.swift
//  mas-cli
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

import Commandant
import CommerceKit
import Result

public struct PurchaseCommand: CommandProtocol {
	public typealias Options = PurchaseOptions
	public let verb = "purchase"
	public let function = "purchase and download free apps from the Mac App Store"

	/// Designated initializer.
	public init() {
	}

	/// Runs the command.
	public func run(_ options: Options) -> Result<(), MASError> {
		// Try to download applications with given identifiers and collect results
		let downloadResults = options.appIds.compactMap { (appId) -> MASError? in
			if let product = installedApp(appId) {
				printWarning("\(product.appName) has already been purchased.")
				return nil
			}

			return download(appId, isPurchase: true)
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

	fileprivate func installedApp(_ appId: UInt64) -> CKSoftwareProduct? {
		let appId = NSNumber(value: appId)

		let softwareMap = CKSoftwareMap.shared()
		return softwareMap.allProducts()?.first { $0.itemIdentifier == appId }
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
