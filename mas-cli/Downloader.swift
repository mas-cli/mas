//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

typealias DownloadCompletion = (purchase: SSPurchase!, completed: Bool, error: NSError?, response: SSPurchaseResponse!) -> ()

func download(adamId: UInt64, completion:DownloadCompletion) {
    let buyParameters = "productType=C&price=0&salableAdamId=\(adamId)&pricingParameters=STDRDL"
    let purchase = SSPurchase()
    purchase.buyParameters = buyParameters
    purchase.itemIdentifier = adamId
    purchase.accountIdentifier = primaryAccount().dsID
    purchase.appleID = primaryAccount().identifier
    
    let downloadMetadata = SSDownloadMetadata()
    downloadMetadata.kind = "software"
    downloadMetadata.itemIdentifier = adamId
    
    purchase.downloadMetadata = downloadMetadata
    
    let purchaseController = CKPurchaseController.sharedPurchaseController()
    purchaseController.performPurchase(purchase, withOptions: 0, completionHandler: completion)
    while true {
        NSRunLoop.mainRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 10))
    }
}