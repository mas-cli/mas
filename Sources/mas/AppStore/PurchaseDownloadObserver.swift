//
//  PurchaseDownloadObserver.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit

private let downloadingPhase = 0 as Int64
private let installingPhase = 1 as Int64
private let initialPhase = 4 as Int64
private let downloadedPhase = 5 as Int64

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
                case downloadingPhase:
                    if priorPhaseType == initialPhase {
                        clearLine()
                        printInfo("Downloading \(download.progressDescription)")
                    }
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

    func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
        // do nothing
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
            errorHandler?(.downloadFailed(error: status.error as NSError))
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
    func observeDownloadQueue(_ downloadQueue: CKDownloadQueue = CKDownloadQueue.shared()) async throws {
        let observerID = downloadQueue.add(self)
        defer { downloadQueue.remove(observerID) }

        try await withCheckedThrowingContinuation { continuation in
            completionHandler = {
                continuation.resume()
            }
            errorHandler = { error in
                continuation.resume(throwing: error)
            }
        }
    }
}
