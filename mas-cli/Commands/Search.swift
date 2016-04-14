//
//  Search.swift
//  mas-cli
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct SearchCommand: CommandType {
    typealias Options = SearchOptions
    let verb = "search"
    let function = "Search for apps from the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        let searchRequest = NSURLRequest(URL: NSURL(string: searchURLString(options.appName))!)
        
        guard let searchData = NSURLSession.requestSynchronousData(searchRequest),
              let searchJsonString = try? NSJSONSerialization.JSONObjectWithData(searchData, options: []) as! Dictionary<String, AnyObject> else {
            return .Failure(MASError(code:.SearchError))
        }
        
        guard let resultCount = searchJsonString["resultCount"] as? Int where resultCount > 0,
              let results = searchJsonString["results"] as? Array<Dictionary<String, AnyObject>> else {
            print("No apps found")
            return .Failure(MASError(code:.NoSearchResultsFound))
        }
        
        for result in results {
            if let appName = result["trackName"] as? String,
                   appId = result["trackId"] as? Int {
                print("\(String(appId)) \(appName)")
            }
        }
        
        return .Success(())
    }
    
    func searchURLString(appName: String) -> String {
        return "https://itunes.apple.com/search?entity=macSoftware&term=\(appName)&attribute=allTrackTerm"
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
