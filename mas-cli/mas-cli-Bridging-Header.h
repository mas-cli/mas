//
//  mas-cli-Bridging-Header.h
//  mas-cli
//
//  Created by Andrew Naylor on 11/07/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

#ifndef mas_cli_Bridging_Header_h
#define mas_cli_Bridging_Header_h

@import Foundation;

#import "ISStoreAccount.h"

#import "CKAccountStore.h"
#import "CKDownloadQueue.h"
#import "CKDownloadQueueClient.h"
#import "CKPurchaseController.h"
#import "CKSoftwareMap.h"
#import "CKUpdateController.h"

#import "SSDownload.h"
#import "SSDownloadMetadata.h"
#import "SSDownloadPhase.h"
#import "SSDownloadStatus.h"
#import "SSPurchase.h"
#import "SSPurchaseResponse.h"

@protocol CKDownloadQueueObserver

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@end

#endif /* mas_cli_Bridging_Header_h */
