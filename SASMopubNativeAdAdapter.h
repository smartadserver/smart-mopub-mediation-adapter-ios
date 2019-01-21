//
//  SASMopubNativeAdAdapter.h
//  SmartAdServer
//
//  Created by Thomas Geley on 26/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import "MoPub.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithSASNativeAd:(SASNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
