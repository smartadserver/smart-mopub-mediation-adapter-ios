//
//  SASMopubAdapterConfiguration.h
//  Sample
//
//  Created by Julien Gomez on 15/01/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

#import "MPBaseAdapterConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Provides adapter information back to the SDK and is the main access point
 for all adapter-level configuration.
 */
@interface SASMopubAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString *adapterVersion;
@property (nonatomic, copy, readonly) NSString *biddingToken;
@property (nonatomic, copy, readonly) NSString *moPubNetworkName;
@property (nonatomic, copy, readonly) NSString *networkSdkVersion;

+ (void)updateInitializationParameters:(NSDictionary *)parameters;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;

@end

NS_ASSUME_NONNULL_END
