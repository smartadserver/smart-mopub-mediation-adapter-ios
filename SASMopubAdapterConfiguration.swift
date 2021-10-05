//
//  SASMopubAdapterConfiguration.swift
//  SASMopubAdapterConfiguration
//
//  Created by Loïc GIRON DIT METAZ on 02/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

/**
 Provides adapter information back to the SDK and is the main access point
 for all adapter-level configuration.
 */
@objc(SASMopubAdapterConfiguration)
class SASMopubAdapterConfiguration: MPBaseAdapterConfiguration {
    
    override var adapterVersion: String {
        return "3.0"
    }
    
    override var biddingToken: String? {
        return nil
    }
    
    override var moPubNetworkName: String {
        return "SmartAdServer"
    }
    
    override var networkSdkVersion: String {
        return "7.12"
    }
    
}
