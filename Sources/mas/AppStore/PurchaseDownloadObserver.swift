//
//  PurchaseDownloadObserver.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit
import StoreFoundation

private let downloadingPhase: Int64 = 0
private let installingPhase: Int64 = 1
private let downloadedPhase: Int64 = 5

class PurchaseDownloadObserver: CKDownloadQueueObserver {
    private let purchase: SSPurchase
    private var completionHandler: (() -> Void)?
    private var errorHandler: ((MASError) -> Void)?
    private var priorPhaseType: Int64?

    init(purchase: SSPurchase) {
        self.purchase = purchase
    }

    deinit {
        // do nothing
    }

    func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
        guard
            download.metadata.itemIdentifier == purchase.itemIdentifier,
            let status = download.status
        else {
            return
        }

        if status.isFailed || status.isCancelled {
            queue.removeDownload(withItemIdentifier: download.metadata.itemIdentifier)
        } else {
            if priorPhaseType != status.activePhase.phaseType {
                switch status.activePhase.phaseType {
                case downloadedPhase:
                    if priorPhaseType == downloadingPhase {
                        clearLine()
                        printInfo("Downloaded \(download.progressDescription)")
                    }
                case installingPhase:
                    clearLine()
                    printInfo("Installing \(download.progressDescription)")
                default:
                    break
                }
                priorPhaseType = status.activePhase.phaseType
            }
            progress(status.progressState)
        }
    }

    func downloadQueue(_: CKDownloadQueue, changedWithAddition download: SSDownload) {
        guard download.metadata.itemIdentifier == purchase.itemIdentifier else {
            return
        }
        clearLine()
        printInfo("Downloading \(download.progressDescription)")
    }

    func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
        guard
            download.metadata.itemIdentifier == purchase.itemIdentifier,
            let status = download.status
        else {
            return
        }

        clearLine()
        if status.isFailed {
            errorHandler?(.downloadFailed(error: status.error as NSError?))
        } else if status.isCancelled {
            errorHandler?(.cancelled)
        } else {
            printInfo("Installed \(download.progressDescription)")
            completionHandler?()
        }
    }
}

private struct ProgressState {
    let percentComplete: Float
    let phase: String

    var percentage: String {
        // swiftlint:disable:next no_magic_numbers
        String(format: "%.1f%%", floor(percentComplete * 1000) / 10)
    }
}

private func progress(_ state: ProgressState) {
    // Don't display the progress bar if we're not on a terminal
    guard isatty(fileno(stdout)) != 0 else {
        return
    }

    let barLength = 60
    let completeLength = Int(state.percentComplete * Float(barLength))
    let bar = (0..<barLength).map { $0 < completeLength ? "#" : "-" }.joined()
    clearLine()
    print("\(bar) \(state.percentage) \(state.phase)", terminator: "")
    fflush(stdout)
}

private extension SSDownload {
    var progressDescription: String {
        "\(metadata.title) (\(metadata.bundleVersion ?? "unknown version"))"
    }
}

private extension SSDownloadStatus {
    var progressState: ProgressState {
        ProgressState(percentComplete: percentComplete, phase: activePhase.phaseDescription)
    }
}

private extension SSDownloadPhase {
    var phaseDescription: String {
        switch phaseType {
        case downloadingPhase:
            return "Downloading"
        case installingPhase:
            return "Installing"
        default:
            return "Waiting"
        }
    }
}

extension PurchaseDownloadObserver {
    func observeDownloadQueue(_ downloadQueue: CKDownloadQueue = CKDownloadQueue.shared()) -> Promise<Void> {
        let observerID = downloadQueue.add(self)

        return Promise<Void> { seal in
            errorHandler = seal.reject
            completionHandler = seal.fulfill_
        }
        .ensure {
            downloadQueue.remove(observerID)
        }
    }
}
