//
//  DownloadQueueObserver.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

@objc class DownloadQueueObserver: CKDownloadQueueObserver {
    func downloadQueue(queue: CKDownloadQueue, statusChangedForDownload download: SSDownload!) {
        if let activePhase = download.status.activePhase {
            let percentage = String(Int(floor(download.status.percentComplete * 100))) + "%"
            //            let phase = String(activePhase.phaseType)
            print("\(csi)2K\(csi)0G" + percentage)
        }
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithAddition download: SSDownload!) {
        print("Downloading: " + download.metadata.title)
    }
    
    func downloadQueue(queue: CKDownloadQueue, changedWithRemoval download: SSDownload!) {
        print("")
        print("Finished: " + download.metadata.title)
        exit(EXIT_SUCCESS)
    }
}