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
    var identifier: Int {
        switch self {
        case .mojave: return 1_398_502_828
        case .highSierra: return 124_628_474
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
}

extension MacOS: CustomStringConvertible {
    var description: String {
        return "\(name) \(version) (\(identifier))"
    }
}
