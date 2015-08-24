//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

func download(adamId: UInt64) -> MASError? {

    if let account = ISStoreAccount.primaryAccount {
        let group = dispatch_group_create()
        let purchase = SSPurchase(adamId: adamId, account: account)
        
        var purchaseError: MASError?
        
        purchase.perform { purchase, completed, error, response in
            if completed {
                let observer = PurchaseDownloadObserver(purchase: purchase)
                observer.onCompletion {
                    dispatch_group_leave(group)
                }
                
                CKDownloadQueue.sharedDownloadQueue().addObserver(observer)
            }
            else {
                purchaseError = MASError(code: .PurchaseError, sourceError: error)
                dispatch_group_leave(group)
            }
        }
        
        dispatch_group_enter(group)
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        return purchaseError
    }
    else {
        return MASError(code: .NotSignedIn)
    }
}
