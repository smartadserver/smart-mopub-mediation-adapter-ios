//
//  SASMopubUtils.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 14/01/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASMopubUtils

+ (nullable SASAdPlacement *)adPlacementWithCustomEventInfo:(NSDictionary *)info error:(NSError **)error {
    
    // Failing if custom info are invalid
    if (![[info objectForKey:@"siteid"] respondsToSelector:@selector(integerValue)]
        || ![[info objectForKey:@"formatid"] respondsToSelector:@selector(integerValue)]
        || ![[info objectForKey:@"pageid"] isKindOfClass:[NSString class]]) {
        
        if (error != nil) {
            *error = [NSError errorWithDomain:SASMopubAdapterErrorDomain
                                         code:SASMopubAdapterErrorCode
                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid custom event info: %@", info] }];
        }
        
        return nil;
    }
    
    // Extracting placement from custom event info
    SASAdPlacement *adPlacement = [SASAdPlacement adPlacementWithSiteId:[[info objectForKey:@"siteid"] integerValue]
                                                               pageName:[info objectForKey:@"pageid"]
                                                               formatId:[[info objectForKey:@"formatid"] integerValue]
                                                       keywordTargeting:[info objectForKey:@"target"]];
    
    // Setting the site ID and the base URL
    [[SASConfiguration sharedInstance] configureWithSiteId:adPlacement.siteId];
    [[SASConfiguration sharedInstance] setPrimarySDK:NO];
    
    return adPlacement;
}

@end

NS_ASSUME_NONNULL_END
