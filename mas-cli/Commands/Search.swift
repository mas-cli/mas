//
//  Search.swift
//  mas-cli
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct ResultKeys {
    static let ResultCount = "resultCount"
    static let Results = "results"
    static let TrackName = "trackName"
    static let TrackId = "trackId"
}

struct SearchCommand: CommandType {
    typealias Options = SearchOptions
    let verb = "search"
    let function = "Search for apps from the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        
        guard let searchURLString = searchURLString(options.appName),
              let searchJson = NSURLSession.requestSynchronousJSONWithURLString(searchURLString) as? [String: AnyObject] else {
            return .Failure(MASError(code:.SearchError))
        }
        
        guard let resultCount = searchJson[ResultKeys.ResultCount] as? Int where resultCount > 0,
              let results = searchJson[ResultKeys.Results] as? [[String: AnyObject]] else {
            print("No results found")
            return .Failure(MASError(code:.NoSearchResultsFound))
        }
        
        for result in results {
            if let appName = result[ResultKeys.TrackName] as? String,
                   appId = result[ResultKeys.TrackId] as? Int {
                print("\(String(appId)) \(appName)")
            }
        }
        
        return .Success(())
    }
    
    func searchURLString(appName: String) -> String? {
        if let urlEncodedAppName = appName.URLEncodedString() {
            return "https://itunes.apple.com/search?entity=macSoftware&term=\(urlEncodedAppName)&attribute=allTrackTerm"
        }
        return nil
    }
}

struct SearchOptions: OptionsType {
    let appName: String
    
    static func create(appName: String) -> SearchOptions {
        return SearchOptions(appName: appName)
    }
    
    static func evaluate(m: CommandMode) -> Result<SearchOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app name to search")
    }
}
