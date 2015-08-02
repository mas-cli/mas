//
//  main.swift
//  mas-cli
//
//  Created by Andrew Naylor on 11/07/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Foundation

var client = ISStoreClient(storeClientType: 0)

func primaryAccount() -> ISStoreAccount {
    let accountController = CKAccountStore.sharedAccountStore()
    return accountController.primaryAccount
}

@objc class Observer: CKDownloadQueueObserver {
    func downloadQueue(queue: CKDownloadQueue, statusChangedForDownload download: SSDownload!) {
        if let activePhase = download.status.activePhase {
            let percentage = String(Int(floor(download.status.percentComplete * 100))) + "%"
//            let phase = String(activePhase.phaseType)
            print("\u{001B}[2K\r" + percentage + " " + download.metadata.title, appendNewline: false)
        }
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithAddition download: SSDownload!) {
        print("Downloading: " + download.metadata.title)
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithRemoval download: SSDownload!) {
        print("")
        print("Finished: " + download.metadata.title)
        exit(EXIT_SUCCESS)
    }
}

var downloadQueue = CKDownloadQueue.sharedDownloadQueue()
downloadQueue.addObserver(Observer())

var softwareMap = CKSoftwareMap.sharedSoftwareMap()
//print(softwareMap.allProducts())
//print(softwareMap.productForBundleIdentifier("com.apple.iBooksAuthor"))
//print(softwareMap.adaptableBundleIdentifiers())

func download(adamId: UInt64, completion:(purchase: SSPurchase!, completed: Bool, error: NSError?, response: SSPurchaseResponse!) -> ()) {
    let buyParameters = "productType=C&price=0&salableAdamId=" + String(adamId) + "&pricingParameters=STDRDL"
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

let paintCode: UInt64 = 808809998
let xcode: UInt64 = 497799835
let aperture: UInt64 = 408981426

struct AccountCommand: CommandType {
    let verb = "account"
    let function = "Prints the primary account Apple ID"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            print(primaryAccount().identifier)
        default:
            break
        }
        return .Success(())
    }
}

struct InstallCommand: CommandType {
    let verb = "install"
    let function = "Install from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        return InstallOptions.evaluate(mode).map { options in
            download(options.appId) { (purchase, completed, error, response) in
                print(purchase)
                print(completed)
                print(error)
                print(response)
            }
        }
    }
}

struct InstallOptions: OptionsType {
    let appId: UInt64
    
    static func create(appId: UInt64) -> InstallOptions {
        return InstallOptions(appId: appId)
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Option(usage: "the app ID to install")
    }
}

struct ListUpdatesCommand: CommandType {
    let verb = "list-updates"
    let function = "Lists pending updates from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let updateController = CKUpdateController.sharedUpdateController()
            print(updateController.availableUpdates())
        default:
            break
        }
        return .Success(())
    }
}

struct ListInstalledCommand: CommandType {
    let verb = "list-installed"
    let function = "Lists apps from the Mac App Store which are currently installed"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let softwareMap = CKSoftwareMap.sharedSoftwareMap()
            let products = softwareMap.allProducts()
            products.map({ product -> Bool in
                print(String(product.itemIdentifier) + " " + product.appName)
                return true
            })
            
        default:
            break
        }
        return .Success(())
    }
}

public enum MASError: ErrorType, Equatable {
    public var description: String {
        return ""
    }
}

public func == (lhs: MASError, rhs: MASError) -> Bool {
    return false
}

let registry = CommandRegistry<MASError>()
let helpCommand = HelpCommand(registry: registry)
registry.register(AccountCommand())
registry.register(InstallCommand())
registry.register(ListInstalledCommand())
registry.register(ListUpdatesCommand())
registry.register(helpCommand)

setbuf(__stdoutp, nil)
registry.main(defaultVerb: helpCommand.verb, errorHandler: { error in
    fputs(error.description + "\n", stderr)
})

