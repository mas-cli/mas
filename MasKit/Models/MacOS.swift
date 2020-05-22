//
//  MacOS0.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/23/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

/// Model representing macOS installers, used by the `os` command.
enum MacOS: CaseIterable {
    case mojave
    case highSierra
    case sierra
    case elCapitan
    case yosemite
    case mavericks

    /// MAS identifier for the installer app.
    var identifier: UInt64 {
        switch self {
        case .mojave: return 1_398_502_828
        case .highSierra: return 1_246_284_741
        case .sierra: return 1_127_487_414
        case .elCapitan: return 1_147_835_434
        case .yosemite: return 915_041_082
        case .mavericks: return 675_248_567
        }
    }

    /// Display name
    var name: String {
        switch self {
        case .mojave: return "Mojave"
        case .highSierra: return "High Sierra"
        case .sierra: return "Sierra"
        case .elCapitan: return "El Capitan"
        case .yosemite: return "Yosemite"
        case .mavericks: return "Mavericks"
        }
    }

    /// Installer store name
    var installerName: String {
        switch self {
        case .mojave, .highSierra, .sierra: return "Install macOS \(name)"
        case .elCapitan, .yosemite, .mavericks: return "Install OS X \(name)"
        }
    }

    /// Common base for all installer bundle identifiers.
    static var bundleIdentifierBase: String { return "com.apple.InstallAssistant" }

    /// Bundle identifier
    var bundleIdentifier: String {
        switch self {
        case .mojave:       return "\(MacOS.bundleIdentifierBase).Mojave"
        case .highSierra:   return "\(MacOS.bundleIdentifierBase).HighSierra"
        case .sierra:       return "\(MacOS.bundleIdentifierBase).Sierra"     // UNCONFIRMED
        case .elCapitan:    return "\(MacOS.bundleIdentifierBase).ElCapitan"  // UNCONFIRMED
        case .yosemite:     return "\(MacOS.bundleIdentifierBase).Yosemite"
        case .mavericks:    return "\(MacOS.bundleIdentifierBase).Mavericks"
        }
    }

    /// Token for use with commands.
    var token: String {
        switch self {
        case .mojave: return "macos-mojave"
        case .highSierra: return "macos-high-sierra"
        case .sierra: return "macos-sierra"
        case .elCapitan: return "os-x-el-capitan"
        case .yosemite: return "os-x-yosemite"
        case .mavericks: return "os-x-mavericks"
        }
    }

    var altTokens: [String] {
        switch self {
        case .mojave: return ["mojave"]
        case .highSierra: return ["high-sierra", "highsierra"]
        case .sierra: return ["sierra"]
        case .elCapitan: return ["macos-el-capitan", "el-capitan", "elcapitan"]
        case .yosemite: return ["macos-yosemite", "yosemite"]
        case .mavericks: return ["macos-mavericks", "mavericks"]
        }
    }

    /// Major.minor version of OS
    var version: String {
        switch self {
        case .mojave: return "10.14"
        case .highSierra: return "10.13"
        case .sierra: return "10.12"
        case .elCapitan: return "10.11"
        case .yosemite: return "10.10"
        case .mavericks: return "10.9"
        }
    }

    // https://itunes.apple.com/us/app/macos-mojave/id1398502828?mt=12&ign-mpt=uo%3D4
    // https://itunes.apple.com/de/app/macos-sierra/id1127487414?l=en&mt=12
    // https://itunes.apple.com/us/app/macos-high-sierra/id1246284741?ls=1&mt=12
    // https://itunes.apple.com/app/os-x-el-capitan/id1147835434?ls=1&mt=12
    var url: String? {
        switch self {
        case .yosemite, .mavericks:
            return nil
        default:
            return "https://itunes.apple.com/us/app/\(token)/id\(identifier)?mt=12"
        }
    }
}

extension MacOS {
    /// Finds an instance of macOS for a given identifier.
    ///
    /// - Parameter identifier: Numeric app identifier for the OS installer.
    /// - Returns: MacOS case matching the identifier or nil if there are none.
    static func os(withId identifier: Int) -> MacOS? {
        for macos in allCases where macos.identifier == identifier {
            return macos
        }
        return nil
    }

    /// Finds an instance of macOS that has the token.
    ///
    /// - Parameter token: Short identifier for an OS.
    /// - Returns: MacOS case matching the token or nil if there are none.
    static func os(withToken token: String) -> MacOS? {
        for macos in allCases {
            if macos.token == token || macos.altTokens.contains(token) {
                return macos
            }
        }
        return nil
    }

    /// Look up OS based on bundle identifier.
    ///
    /// - Parameter bundleIdentifier: Bundle identifire of app.
    /// - Returns: MacOS enum case if one matches.
    static func os(fromBundleIdentifier bundleIdentifier: String) -> MacOS? {
        guard bundleIdentifier.starts(with: MacOS.bundleIdentifierBase)
        else { return nil }

        for macos in MacOS.allCases where macos.bundleIdentifier == bundleIdentifier {
            return macos
        }

        return nil
    }
}

extension MacOS: CustomStringConvertible {
    /// Human-readable description.
    var description: String {
        let output = "\(name) \(version) (\(identifier))"
        guard let url = url else { return output }
        return output + " \(url)"
    }
}
