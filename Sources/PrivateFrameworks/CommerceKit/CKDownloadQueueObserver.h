//
//  CKDownloadQueueObserver.h
//  mas-cli
//
//  Created by Ben Chatelain on 7/8/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

#import "CKDownloadQueue.h"
@import StoreFoundation;

@protocol CKDownloadQueueObserver

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@end
