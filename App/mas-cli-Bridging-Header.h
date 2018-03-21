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

#import <StoreFoundation/ISStoreAccount.h>

#import <CommerceKit/CKAccountStore.h>
#import <CommerceKit/CKDownloadQueue.h>
#import <CommerceKit/CKPurchaseController.h>
#import <CommerceKit/CKSoftwareMap.h>
#import <CommerceKit/CKUpdateController.h>

#import <StoreFoundation/CKUpdate.h>
#import <StoreFoundation/SSDownload.h>
#import <StoreFoundation/SSDownloadMetadata.h>
#import <StoreFoundation/SSDownloadPhase.h>
#import <StoreFoundation/SSDownloadStatus.h>
#import <StoreFoundation/SSPurchaseResponse.h>
#import <StoreFoundation/ISStoreClient.h>
#import <StoreFoundation/ISAuthenticationContext.h>
#import <StoreFoundation/ISAuthenticationResponse.h>
#import <StoreFoundation/ISServiceRemoteObject-Protocol.h>
#import <StoreFoundation/ISAccountService-Protocol.h>
#import "ISAccountService-Protocol.h"
#import <StoreFoundation/ISServiceProxy.h>

@protocol CKDownloadQueueObserver

- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithAddition:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue changedWithRemoval:(SSDownload *)download;
- (void)downloadQueue:(CKDownloadQueue *)downloadQueue statusChangedForDownload:(SSDownload *)download;

@end

NSString* CKDownloadDirectory(NSString *target);

#endif /* mas_cli_Bridging_Header_h */
