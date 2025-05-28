//
// CKDownloadQueueObserver-Protocol.h
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol CKDownloadQueueObserver

@required

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@optional

@end

NS_ASSUME_NONNULL_END
