//
//  PurchaseDownloadObserver.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

let csi = "\u{001B}["

@objc class PurchaseDownloadObserver: NSObject, CKDownloadQueueObserver {
    let purchase: SSPurchase
    var completionHandler: (() -> ())?
    var errorHandler: ((MASError) -> ())?
    
    init(purchase: SSPurchase) {
        self.purchase = purchase
    }
    
    func downloadQueue(queue: CKDownloadQueue, statusChangedForDownload download: SSDownload!) {
        if download.metadata.itemIdentifier != purchase.itemIdentifier {
            return
        }
        let status = download.status
        if status.failed || status.cancelled {
            queue.removeDownloadWithItemIdentifier(download.metadata.itemIdentifier)
        }
        else if let state = status.progressState {
            progress(state)
        }
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithAddition download: SSDownload!) {
        clearLine()
        print("==> Downloading " + download.metadata.title)
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithRemoval download: SSDownload!) {
        clearLine()
        let status = download.status
        if status.failed {
            print("==> Download Failed")
            errorHandler?(MASError(code: .DownloadFailed, sourceError: status.error))
        }
        else if status.cancelled {
            print("==> Download Cancelled")
            errorHandler?(MASError(code: .Cancelled))
        }
        else {
            print("==> Installed " + download.metadata.title)
            completionHandler?()
        }
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
    guard isatty(fileno(stdout)) != 0 else {
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
    clearLine()
    print("\(bar) \(state.percentage) \(state.phase)", terminator: "")
    fflush(stdout)
}

func clearLine() {
    guard isatty(fileno(stdout)) != 0 else {
        return
    }
    print("\(csi)2K\(csi)0G")
    fflush(stdout)
}

extension SSDownloadStatus {
    var progressState: ProgressState? {
        if let phase = activePhase {
            return ProgressState(percentComplete: percentComplete, phase: phase.phaseDescription)
        }
        else {
            return nil
        }
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