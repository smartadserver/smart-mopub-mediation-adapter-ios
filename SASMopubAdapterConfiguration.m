//
//  SASMopubAdapterConfiguration.m
//  Sample
//
//  Created by Julien Gomez on 15/01/2021.
//  Copyright © 2021 Smart AdServer. All rights reserved.
//

#import "SASMopubAdapterConfiguration.h"


@implementation SASMopubAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"2.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"SmartAdServer";
}

- (NSString *)networkSdkVersion {
    return @"7.8";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {

}

@end
