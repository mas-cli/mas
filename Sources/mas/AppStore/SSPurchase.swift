//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import StoreFoundation

extension SSPurchase {
	convenience init(adamID: ADAMID, getting: Bool) async {
		self.init(
			buyParameters: """
				productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
				\(getting ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
				"""
		)

		// Possibly unnecessary…
		isRedownload = !getting

		itemIdentifier = adamID

		let downloadMetadata = SSDownloadMetadata(kind: "software")
		downloadMetadata.itemIdentifier = adamID
		self.downloadMetadata = downloadMetadata

		do {
			let (emailAddress, dsID) = try await appleAccount
			accountIdentifier = dsID
			appleID = emailAddress
		} catch {
			// Do nothing
		}
	}
}
