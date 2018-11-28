//
//  PlayTunesIAPProducts.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/10/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

//let SubScript2: ProductIdentifier = "Renewal_1"

let kUsingSubScript_1W_toss = false

let SubScript_1W_toss: ProductIdentifier = "com.musikyoshi.playtunes.PT001_EN_1W_SUB_toss"
let SubScript_1M: ProductIdentifier = "com.musikyoshi.playtunes.PTB01_EN_1M_SUB"
let SubScript_6M: ProductIdentifier = "com.musikyoshi.playtunes.PTB01_EN_6M_SUB"

public struct PlayTunesIAPProducts {
    
    // DELME
    public static let SwiftShopping = "com.razeware.razefaces.swiftshopping"
    
    private static let productIdentifiers: Set<ProductIdentifier> =
        kUsingSubScript_1W_toss ?   [SubScript_1W_toss,
                                     SubScript_6M,
                                     SubScript_1M]
                                :   [SubScript_6M,
                                     SubScript_1M]

//    private static let productIdentifiers: Set<ProductIdentifier> = [SubScript_1W_toss,
//                                                                     SubScript_1M,
//                                                                     SubScript_6M]
//
    public static let store = IAPHelper(prodIds: PlayTunesIAPProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
