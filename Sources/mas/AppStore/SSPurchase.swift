//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import StoreFoundation

extension SSPurchase {
	convenience init(adamID: ADAMID, purchasing: Bool) async {
		self.init(
			buyParameters: """
				productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
				\(purchasing ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
				"""
		)

		// Possibly unnecessary…
		isRedownload = !purchasing

		itemIdentifier = adamID

		let downloadMetadata = SSDownloadMetadata(kind: "software")
		downloadMetadata.itemIdentifier = adamID
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
