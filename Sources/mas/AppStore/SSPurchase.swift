//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import StoreFoundation

extension SSPurchase {
	convenience init(appID: AppID, purchasing: Bool) async {
		self.init()

		var parameters =
			[
				"productType": "C",
				"price": 0,
				"salableAdamId": appID,
				"pg": "default",
				"appExtVrsId": 0,
			] as [String: Any]

		if purchasing {
			parameters["macappinstalledconfirmed"] = 1
			parameters["pricingParameters"] = "STDQ"
			// Possibly unnecessary…
			isRedownload = false
		} else {
			parameters["pricingParameters"] = "STDRDL"
		}

		buyParameters = parameters.map { "\($0)=\($1)" }.joined(separator: "&")

		itemIdentifier = appID

		downloadMetadata = SSDownloadMetadata()
		downloadMetadata.kind = "software"
		downloadMetadata.itemIdentifier = appID

		do {
			let appleAccount = try await appleAccount
			accountIdentifier = appleAccount.dsID
			appleID = appleAccount.emailAddress
		} catch {
			// Do nothing
		}
	}
}
