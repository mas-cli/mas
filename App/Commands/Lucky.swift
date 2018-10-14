//
//  Lucky.swift
//  mas-cli
//
//  Created by Pablo Varela on 05/11/17.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import Result

import CommerceKit

struct LuckyCommand: CommandProtocol {
    typealias Options = LuckyOptions
    let verb = "lucky"
    let function = "Install the first result from the Mac App Store"

    func run(_ options: Options) -> Result<(), MASError> {

        guard let searchURLString = searchURLString(options.appName),
              let searchJson = URLSession.requestSynchronousJSONWithURLString(searchURLString) as? [String: Any] else {
            return .failure(.searchFailed)
        }

        guard let resultCount = searchJson[ResultKeys.ResultCount] as? Int, resultCount > 0,
              let results = searchJson[ResultKeys.Results] as? [[String: Any]] else {
            print("No results found")
            return .failure(.noSearchResultsFound)
        }


        let appId = results[0][ResultKeys.TrackId] as! UInt64
        
        return install(appId, options: options)
    }

    fileprivate func install(_ appId: UInt64, options: Options) -> Result<(), MASError> {
        // Try to download applications with given identifiers and collect results
        let downloadResults = [appId].compactMap { (appId) -> MASError? in
            if let product = installedApp(appId) , !options.forceInstall {
                printWarning("\(product.appName) is already installed")
                return nil
            }
            
            return download(appId)
        }
        
        switch downloadResults.count {
        case 0:
            return .success(())
        case 1:
            return .failure(downloadResults[0])
        default:
            return .failure(.downloadFailed(error: nil))
        }
    }

    fileprivate func installedApp(_ appId: UInt64) -> CKSoftwareProduct? {
        let appId = NSNumber(value: appId)

        let softwareMap = CKSoftwareMap.shared()
        return softwareMap.allProducts()?.first { $0.itemIdentifier == appId }
    }

    func searchURLString(_ appName: String) -> String? {
        if let urlEncodedAppName = appName.URLEncodedString {
            return "https://itunes.apple.com/search?entity=macSoftware&term=\(urlEncodedAppName)&attribute=allTrackTerm"
        }
        return nil
    }
}

struct LuckyOptions: OptionsProtocol {
    let appName: String
    let forceInstall: Bool
    
    static func create(_ appName: String) -> (_ forceInstall: Bool) -> LuckyOptions {
        return { forceInstall in
            return LuckyOptions(appName: appName, forceInstall: forceInstall)
        }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<LuckyOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app name to install")
            <*> m <| Switch(flag: nil, key: "force", usage: "force reinstall")
    }

}
