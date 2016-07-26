//
//  SSPurchase.swift
//  mas-cli
//
//  Created by Andrew Naylor on 25/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

typealias SSPurchaseCompletion = (purchase: SSPurchase!, completed: Bool, error: NSError?, response: SSPurchaseResponse!) -> ()

extension SSPurchase {
    convenience init(adamId: UInt64, account: ISStoreAccount) {
        self.init()
        self.buyParameters = "productType=C&price=0&salableAdamId=\(adamId)&pricingParameters=STDQ"
        self.itemIdentifier = adamId
        self.accountIdentifier = account.dsID
        self.appleID = account.identifier
        
        let downloadMetadata = SSDownloadMetadata()
        downloadMetadata.kind = "software"
        downloadMetadata.itemIdentifier = adamId
        
        self.downloadMetadata = downloadMetadata
    }
    
    func perform(completion: SSPurchaseCompletion) {
        CKPurchaseController.sharedPurchaseController().performPurchase(self, withOptions: 0, completionHandler: completion)
    }
}
