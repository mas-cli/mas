//
//  Utilities.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

func warn(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("Warning: \(message)")
        return
    }
    
    // Yellow, underlined "Warning:" prefix
    print("\(csi)4m\(csi)33mWarning:\(csi)0m \(message)")
}

func error(_ message: String) {
    guard isatty(fileno(stdout)) != 0 else {
        print("Warning: \(message)")
        return
    }
    
    // Red, underlined "Error:" prefix
    print("\(csi)4m\(csi)31mError:\(csi)0m \(message)")
}
