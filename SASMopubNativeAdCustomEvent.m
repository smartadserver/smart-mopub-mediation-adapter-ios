//
//  SASMopubNativeAdCustomEvent.m
//  MoPubSampleApp
//
//  Created by Thomas Geley on 26/12/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "SASMopubNativeAdCustomEvent.h"
#import "SASNativeAd.h"
#import "SASNativeAdImage.h"
#import "SASNativeAdManager.h"
#import "SASMopubNativeAdAdapter.h"
#import "SASMopubCustomEventConstants.h"

#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
#import "MPNativeAdConstants.h"

@interface SASMopubNativeAdCustomEvent ()
@property (nonatomic, strong) SASNativeAdManager *sasNativeAdManager;
@end


@implementation SASMopubNativeAdCustomEvent

#pragma mark - Dealloc

- (void)dealloc {
    [self resetCustomEvent];
}


- (void)resetCustomEvent {
    //Reset AdManager
    _sasNativeAdManager = nil;
}

#pragma mark - Custom Event Extension

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    
    //Reset custom event
    [self resetCustomEvent];
    
    //Create Native Ad Placement from infos dictionary
    SASNativeAdPlacement *placement = [[SASNativeAdPlacement alloc] initWithBaseURL:[NSURL URLWithString:kSASMopubBaseURLString]
                                                                             siteID:[[info objectForKey:@"siteid"] integerValue]
                                                                             pageID:[info objectForKey:@"pageid"]
                                                                           formatID:[[info objectForKey:@"formatid"] integerValue]
                                                                             target:[info objectForKey:@"target"]
                                                                            timeout:10.0];
        
    //Create SASNativeAdManager and request placement
    _sasNativeAdManager = [[SASNativeAdManager alloc] initWithPlacement:placement];
    
    //Request an ad
    [_sasNativeAdManager requestAd:^(SASNativeAd * _Nullable ad, NSError * _Nullable error) {
        if (ad) {
            [self sasNativeAdDidLoad:ad];
        } else {
            [self sasNativeAdDidFailToLoadWithError:error];
        }
    }];

}

#pragma mark - Ad Loading Methods

- (void)sasNativeAdDidLoad:(SASNativeAd *)nativeAd {
    //Init adapter
    SASMopubNativeAdAdapter *adAdapter = [[SASMopubNativeAdAdapter alloc] initWithSASNativeAd:nativeAd];
    
    //Init mopub interface ad
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    //Precache Images if possible
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    if (nativeAd.icon.URL) {
        [imageURLs addObject:nativeAd.icon.URL];
    }
    
    if (nativeAd.coverImage.URL) {
        [imageURLs addObject:nativeAd.coverImage.URL];
    }
    
    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogInfo(@"Error(s) when precaching SASNativeAd Image(s) : %@", errors);
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
        }
    }];
}


- (void)sasNativeAdDidFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Error when loading SASNativeAd : %@", error);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

@end
