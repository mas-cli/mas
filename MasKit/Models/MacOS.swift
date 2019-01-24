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
        case .mojave:       return 1398502828
        case .highSierra:   return 124628474
        case .sierra:       return 1127487414
        case .elCapitan:    return 1147835434
        case .yosemite:     return 915041082
        case .mavericks:    return 675248567
        }
    }

    /// Display name
    var name: String {
        switch self {
        case .mojave:       return "Mojave"
        case .highSierra:   return "High Sierra"
        case .sierra:       return "Sierra"
        case .elCapitan:    return "El Capitan"
        case .yosemite:     return "Yosemite"
        case .mavericks:    return "Mavericks"
        }
    }
}

extension MacOS: CustomStringConvertible {
    var description: String {
        return "\(name) (\(identifier))"
    }
}
