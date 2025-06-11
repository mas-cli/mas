//
// StoreFoundation.h
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

@import Foundation;

@class ISAuthenticationContext, ISAuthenticationResponse, ISOperation, ISStoreClient, SSDownloadAsset, SSOperationProgress;

@protocol ISAccountStoreObserver, ISAssetService, ISDownloadService, ISInAppService, ISServiceRemoteObject, ISTransactionService, ISUIService, ISURLBagObserver;

typedef void (^UnknownBlock)();

#import <ISStoreAccount.h>
#import <ISAccountService-Protocol.h>
#import <ISServiceProxy.h>
#import <SSDownloadMetadata.h>
#import <SSDownloadPhase.h>
#import <SSDownloadStatus.h>
#import <SSDownload.h>
#import <SSPurchase.h>
#import <SSPurchaseResponse.h>
