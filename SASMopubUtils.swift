//
//  SASMopubUtils.swift
//  SASMopubUtils
//
//  Created by Loïc GIRON DIT METAZ on 01/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

class SASMopubUtils {
    
    static let errorDomain = "SASMopubAdapterErrorDomain"
    static let errorCode = 1
    
    static func adPlacement(customEventInfo: [AnyHashable : Any]) throws -> SASAdPlacement {
        
        // Failing if custom info are invalid
        guard let siteIdString = customEventInfo["siteid"] as? String,
              let siteId = Int(siteIdString),
              let pageName = customEventInfo["pageid"] as? String,
              let formatIdString = customEventInfo["formatid"] as? String,
              let formatId = Int(formatIdString) else {
                  
                  throw NSError(
                      domain: SASMopubUtils.errorDomain,
                      code: SASMopubUtils.errorCode,
                      userInfo: [NSLocalizedDescriptionKey: "Invalid custom event info:: \(customEventInfo)"]
                  )
              }
        
        // Extracting placement from custom event info
        let adPlacement = SASAdPlacement(
            siteId: siteId,
            pageName: pageName,
            formatId: formatId,
            keywordTargeting: customEventInfo["target"] as? String
        )
        
        // Setting the site ID and the base URL
        SASConfiguration.shared.configure(siteId: adPlacement.siteId)
        SASConfiguration.shared.primarySDK = false
        
        return adPlacement
    }
    
}
