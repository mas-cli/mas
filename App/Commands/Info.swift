//
//  Info.swift
//  mas-cli
//
//  Created by Denis Lebedev on 21/10/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Foundation

struct InfoCommand: CommandProtocol {
    let verb = "info"
    let function = "Display app information from the Mac App Store"

    func run(_ options: InfoOptions) -> Result<(), MASError> {
        guard let infoURLString = infoURLString(options.appId),
            let searchJson = URLSession.requestSynchronousJSONWithURLString(infoURLString) as? [String: Any] else {
                return .failure(.searchFailed)
        }

        guard let resultCount = searchJson[ResultKeys.ResultCount] as? Int, resultCount > 0,
            let results = searchJson[ResultKeys.Results] as? [[String: Any]],
            let result = results.first else {
                print("No results found")
                return .failure(.noSearchResultsFound)
        }

        print(AppInfoFormatter.format(appInfo: result))

        return .success(())
    }

    private func infoURLString(_ appId: String) -> String? {
        if let urlEncodedAppId = appId.URLEncodedString {
            return "https://itunes.apple.com/lookup?id=\(urlEncodedAppId)"
        }
        return nil
    }
}

struct InfoOptions: OptionsProtocol {
    let appId: String

    static func create(_ appId: String) -> InfoOptions {
        return InfoOptions(appId: appId)
    }

    static func evaluate(_ m: CommandMode) -> Result<InfoOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app id to show info")
    }
}

private struct AppInfoFormatter {

    private enum Keys {
        static let Name = "trackCensoredName"
        static let Version = "version"
        static let Price = "formattedPrice"
        static let Seller = "sellerName"
        static let VersionReleaseDate = "currentVersionReleaseDate"
        static let MinimumOS = "minimumOsVersion"
        static let FileSize = "fileSizeBytes"
        static let AppStoreUrl = "trackViewUrl"
    }

    static func format(appInfo: [String: Any]) -> String {
        let headline = [
            "\(appInfo.stringOrEmpty(key: Keys.Name))",
            "\(appInfo.stringOrEmpty(key: Keys.Version))",
            "[\(appInfo.stringOrEmpty(key: Keys.Price))]",
        ].joined(separator: " ")

        return [
            headline,
            "By: \(appInfo.stringOrEmpty(key: Keys.Seller))",
            "Released: \(humaReadableDate(appInfo.stringOrEmpty(key: Keys.VersionReleaseDate)))",
            "Minimum OS: \(appInfo.stringOrEmpty(key: Keys.MinimumOS))",
            "Size: \(humanReadableSize(appInfo.stringOrEmpty(key: Keys.FileSize)))",
            "From: \(appInfo.stringOrEmpty(key: Keys.AppStoreUrl))",
        ].joined(separator: "\n")
    }

    private static func humanReadableSize(_ size: String) -> String {
        let bytesSize = Int64(size) ?? 0
        return ByteCountFormatter.string(fromByteCount: bytesSize, countStyle: .file)
    }

    private static func humaReadableDate(_ serverDate: String) -> String {
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        serverDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let humanDateFormatter = DateFormatter()
        humanDateFormatter.timeStyle = .none
        humanDateFormatter.dateStyle = .medium
        return serverDateFormatter.date(from: serverDate).flatMap(humanDateFormatter.string(from:)) ?? ""
    }
}

extension Dictionary {
    fileprivate func stringOrEmpty(key: Key) -> String {
        return self[key] as? String ?? ""
    }
}
