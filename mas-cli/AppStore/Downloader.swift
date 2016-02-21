//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

func download(adamId: UInt64) -> MASError? {

    guard let account = ISStoreAccount.primaryAccount else {
        return MASError(code: .NotSignedIn)
    }
    
    let group = dispatch_group_create()
    let purchase = SSPurchase(adamId: adamId, account: account)
    
    var purchaseError: MASError?
    
    dispatch_group_enter(group)
    purchase.perform { purchase, unused, error, response in
        if let error = error {
            purchaseError = MASError(code: .PurchaseError, sourceError: error)
            dispatch_group_leave(group)
            return
        }
        
        if let downloads = response.downloads where downloads.count > 0 {
            let observer = PurchaseDownloadObserver(purchase: purchase)
            
            observer.errorHandler = { error in
                purchaseError = error
                dispatch_group_leave(group)
            }
            
            observer.completionHandler = {
                dispatch_group_leave(group)
            }
            
            CKDownloadQueue.sharedDownloadQueue().addObserver(observer)
        }
        else {
            print("No downloads")
            purchaseError = MASError(code: .NoDownloads)
            dispatch_group_leave(group)
        }
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    return purchaseError
}
