//
//  SSPurchase.swift
//  mas-cli
//
//  Created by Andrew Naylor on 25/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

typealias SSPurchaseCompletion = (_ purchase: SSPurchase?, _ completed: Bool, _ error: Error?, _ response: SSPurchaseResponse?) -> ()

extension SSPurchase {
    convenience init(adamId: UInt64, account: ISStoreAccount, isPurchase: Bool) {
        self.init()
        if isPurchase {
            self.buyParameters = "productType=C&price=0&salableAdamId=\(adamId)&pricingParameters=STDQ&pg=default&appExtVrsId=0&macappinstalledconfirmed=1"
        } else {
            // is redownload, use existing functionality
            self.buyParameters = "productType=C&price=0&salableAdamId=\(adamId)&pricingParameters=STDRDL&pg=default&appExtVrsId=0"
        }
        self.itemIdentifier = adamId
        self.accountIdentifier = account.dsID
        self.appleID = account.identifier

        // Not sure if this is needed, but lets use it here.
        if isPurchase {
            self.isRedownload = false
        }

        let downloadMetadata = SSDownloadMetadata()
        downloadMetadata.kind = "software"
        downloadMetadata.itemIdentifier = adamId
        
        self.downloadMetadata = downloadMetadata
    }
    
    func perform(_ completion: @escaping SSPurchaseCompletion) {
        CKPurchaseController.shared().perform(self, withOptions: 0, completionHandler: completion)
    }
}
