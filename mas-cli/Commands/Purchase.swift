//
//  Purchase.swift
//  mas-cli
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

struct PurchaseCommand: CommandProtocol {
	typealias Options = PurchaseOptions
	let verb = "purchase"
	let function = "purchase and download free apps from the Mac App Store"

	func run(_ options: Options) -> Result<(), MASError> {
		// Try to download applications with given identifiers and collect results
		let downloadResults = options.appIds.flatMap { (appId) -> MASError? in
			if let product = installedApp(appId) {
				printWarning("\(product.appName) has already been purchased.")
				return nil
			}

			return download(appId, isPurchase: true)
		}

		switch downloadResults.count {
		case 0:
			return .success()
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

struct PurchaseOptions: OptionsProtocol {
	let appIds: [UInt64]

	static func create(_ appIds: [Int]) -> PurchaseOptions {
		return PurchaseOptions(appIds: appIds.map{UInt64($0)})
	}

	static func evaluate(_ m: CommandMode) -> Result<PurchaseOptions, CommandantError<MASError>> {
		return create
			<*> m <| Argument(usage: "app ID(s) to install")
	}
}
