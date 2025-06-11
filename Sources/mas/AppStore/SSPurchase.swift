//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import StoreFoundation

extension SSPurchase {
	convenience init(appID: AppID, purchasing: Bool) async {
		self.init(
			buyParameters: """
				productType=C&price=0&salableAdamId=\(appID)&pg=default&appExtVrsId=0&pricingParameters=\
				\(purchasing ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")
				"""
		)

		// Possibly unnecessary…
		isRedownload = !purchasing

		itemIdentifier = appID

		let downloadMetadata = SSDownloadMetadata()
		downloadMetadata.kind = "software"
		downloadMetadata.itemIdentifier = appID
		self.downloadMetadata = downloadMetadata

		do {
			let appleAccount = try await appleAccount
			accountIdentifier = appleAccount.dsID
			appleID = appleAccount.emailAddress
		} catch {
			// Do nothing
		}
	}
}
