//
//  SASMopubUtils.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 14/01/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>

#define SASMopubAdapterBaseURLString    @"https://mobile.smartadserver.com"

#define SASMopubAdapterErrorDomain      @"SASMopubAdapterErrorDomain"
#define SASMopubAdapterErrorCode        1

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubUtils : NSObject

+ (nullable SASAdPlacement *)adPlacementWithCustomEventInfo:(NSDictionary *)info error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
