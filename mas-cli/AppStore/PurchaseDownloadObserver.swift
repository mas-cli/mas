//
//  PurchaseDownloadObserver.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

let csi = "\u{001B}["

@objc class PurchaseDownloadObserver: CKDownloadQueueObserver {
    let purchase: SSPurchase
    var completionHandler: (() -> ())?
    var started = false
    
    init(purchase: SSPurchase) {
        self.purchase = purchase
    }
    
    func downloadQueue(queue: CKDownloadQueue, statusChangedForDownload download: SSDownload!) {
        if !started {
            return
        }
        progress(download.status.progressState)
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithAddition download: SSDownload!) {
        started = true
        println("==> Downloading " + download.metadata.title)
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithRemoval download: SSDownload!) {
        println("")
        println("==> Installed " + download.metadata.title)
        if let complete = self.completionHandler {
            complete()
        }
    }
    
    func onCompletion(complete: () -> ()) {
        self.completionHandler = complete
    }
}

struct ProgressState {
    let percentComplete: Float
    let phase: String
    
    var percentage: String {
        return String(format: "%.1f%%", arguments: [floor(percentComplete * 100)])
    }
}

func progress(state: ProgressState) {
    // Don't display the progress bar if we're not on a terminal
    if isatty(fileno(stdout)) == 0 {
        return
    }
    
    let barLength = 60
    
    let completeLength = Int(state.percentComplete * Float(barLength))
    var bar = ""
    for i in 0..<barLength {
        if i < completeLength {
            bar += "#"
        }
        else {
            bar += "-"
        }
    }
    print("\(csi)2K\(csi)0G\(bar) \(state.percentage) \(state.phase)")
    fflush(stdout)
}

extension SSDownloadStatus {
    var progressState: ProgressState {
        let phase = activePhase?.phaseDescription ?? "Waiting"
        return ProgressState(percentComplete: percentComplete, phase: phase)
    }
}

extension SSDownloadPhase {
    var phaseDescription: String {
        switch phaseType {
        case 0:
            return "Downloading"
        case 1:
            return "Installing"
        default:
            return "Waiting"
        }
    }
}