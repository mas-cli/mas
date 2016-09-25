//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

func download(_ adamId: UInt64) -> MASError? {

    guard let account = ISStoreAccount.primaryAccount else {
        return MASError(code: .notSignedIn)
    }
    
    let group = DispatchGroup()
    let purchase = SSPurchase(adamId: adamId, account: account)
    
    var purchaseError: MASError?
    var observerIdentifier: Any? = nil
    
    group.enter()
    purchase.perform { purchase, _, error, response in
        if let error = error {
            purchaseError = MASError(code: .purchaseError, sourceError: error as NSError)
            group.leave()
            return
        }
        
        if let downloads = response?.downloads, downloads.count > 0, let purchase = purchase {
            let observer = PurchaseDownloadObserver(purchase: purchase)

            observer.errorHandler = { error in
                purchaseError = error
                group.leave()
            }
            
            observer.completionHandler = {
                group.leave()
            }

            let downloadQueue = CKDownloadQueue.shared()
            observerIdentifier = downloadQueue?.add(observer) as Any?
        }
        else {
            print("No downloads")
            purchaseError = MASError(code: .noDownloads)
            group.leave()
        }
    }
    
    let _ = group.wait(timeout: DispatchTime.distantFuture)
    
    if let observerIdentifier = observerIdentifier {
        CKDownloadQueue.shared().removeObserver(observerIdentifier)
    }

    return purchaseError
}

