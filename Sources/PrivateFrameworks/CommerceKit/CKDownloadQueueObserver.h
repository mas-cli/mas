//
// CKDownloadQueueObserver.h
// mas
//
// Created by Ben Chatelain on 2018-07-08.
// Copyright © 2018 mas-cli. All rights reserved.
//

#import "CKDownloadQueue.h"
@import StoreFoundation;

@protocol CKDownloadQueueObserver

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@end
