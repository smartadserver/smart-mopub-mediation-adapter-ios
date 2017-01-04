//
//  SASMopubNativeAdAdapter.h
//  MoPubSampleApp
//
//  Created by Thomas Geley on 26/12/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPNativeAdAdapter.h"

@class SASNativeAd;

@interface SASMopubNativeAdAdapter : NSObject <MPNativeAdAdapter>
- (instancetype)initWithSASNativeAd:(SASNativeAd *)nativeAd;
@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;
@end
