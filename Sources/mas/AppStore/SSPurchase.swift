//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import StoreFoundation

extension SSPurchase {
	convenience init(_ action: AppStoreAction, appWithADAMID adamID: ADAMID) async {
		self.init(
			buyParameters: """
				productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
				\(action == .get ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
				"""
		)

		// Possibly unnecessary…
		isRedownload = action != .get
		isUpdate = action == .update

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
