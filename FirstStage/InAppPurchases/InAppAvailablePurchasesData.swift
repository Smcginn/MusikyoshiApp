//
//  InAppAvailablePurchasesData.swift
//  PlayTunes-debug
//
//  Created by Scott Freshour on 11/8/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

typealias AvailIapPurchsMgr = AvailableInAppPurchasesMgr


struct AvailableInAppPurchaseData {
    var prodIdentifier: String
    var prodDescription: String
    var prodTitle: String
    var prodPrice: NSDecimalNumber
    var prodPriceLocale: Locale
    var prodPriceStr: String

    init ( prodIdentifier:     String,
           prodDescription:    String,
           prodTitle:          String,
           prodPrice:          NSDecimalNumber,
           prodPriceLocale:    Locale,
           prodPriceStr:       String)  {
        self.prodIdentifier     = prodIdentifier
        self.prodDescription    = prodDescription
        self.prodTitle          = prodTitle
        self.prodPrice          = prodPrice
        self.prodPriceLocale    = prodPriceLocale
        self.prodPriceStr       = prodPriceStr
    }
}

class AvailableInAppPurchasesMgr {
    
    static let sharedInstance = AvailableInAppPurchasesMgr()

    var availIAPs: [AvailableInAppPurchaseData] = []
    
    func addOneInAppPurchaseData(data: AvailableInAppPurchaseData) {
        availIAPs.append(data)
    }
    
    func clearAvailableIAPPurcahasesData() {
        availIAPs.removeAll()
    }
    
    func numIAPEntries() -> Int {
        return availIAPs.count
    }
    
    func getPriceForEntry(idx: Int) -> String {
        guard idx >= 0 && idx < availIAPs.count else {
            return ""
        }
        
        if availIAPs[idx].prodPriceStr.isNotEmpty {
            return availIAPs[idx].prodPriceStr
        } else {
            var retStr = String( "\(availIAPs[idx].prodPrice)" )
            let currCode = availIAPs[idx].prodPriceLocale.currencyCode
            var currCodeStr = ""
            if currCode != nil {
                currCodeStr = currCode!
            }
            retStr += " " + currCodeStr
            return retStr
        }
    }

    func getProductIDForEntry(idx: Int) -> String {
        guard idx >= 0 && idx < availIAPs.count else {
            return ""
        }
        
        let retStr = availIAPs[idx].prodIdentifier
        return retStr
    }
    
    func getProdTitleForEntry(idx: Int) -> String {
        guard idx >= 0 && idx < availIAPs.count else {
            return ""
        }
        
        let retStr = availIAPs[idx].prodTitle
        return retStr
    }
    
    func getProdDescriptionForEntry(idx: Int) -> String {
        guard idx >= 0 && idx < availIAPs.count else {
            return ""
        }
        
        let retStr = availIAPs[idx].prodDescription
        return retStr
    }
    
    func printAvailableIAPPurcahasesData() {
        
        print("\n------------------------------------------------------")
        print("\n   SKProduct Data retrieved from Apple:")

        for oneSKProdData in availIAPs {
            print("\n\t-----------------------------------------------")
            print("\tProduct Title:         \(oneSKProdData.prodTitle)")
            print("\tProduct Description:   \(oneSKProdData.prodDescription)")
            print("\tProduct Price:         \(oneSKProdData.prodPrice)")
            print("\tProduct Price Locale:  \(oneSKProdData.prodPriceLocale)")
            print("\tProduct Identifier:    \(oneSKProdData.prodIdentifier)")
            print("\t-----------------------------------------------\n")
        }
        print("------------------------------------------------------\n")
    }
}





