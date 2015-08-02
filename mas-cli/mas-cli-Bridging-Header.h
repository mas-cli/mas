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

#import "ISServiceRemoteObject-Protocol.h"
#import "ISAccountService-Protocol.h"
#import "ISTransactionService-Protocol.h"
#import "ISServiceProxy.h"
#import "ISServiceClientInterface.h"
#import "ISStoreClient.h"
#import "ISStoreAccount.h"

#import "CKAccountStore.h"
#import "CKDownloadQueue.h"
#import "CKDownloadQueueClient.h"
#import "CKSoftwareMap.h"
#import "SSDownload.h"
#import "SSDownloadStatus.h"
#import "SSDownloadPhase.h"
#import "SSPurchase.h"
#import "SSPurchaseResponse.h"
#import "SSDownloadMetadata.h"
#import "CKItemLookupRequest.h"
#import "CKItemLookupResponse.h"
#import "CKPurchaseController.h"
#import "CKUpdateController.h"

@protocol CKDownloadQueueObserver

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@end

#endif /* mas_cli_Bridging_Header_h */
