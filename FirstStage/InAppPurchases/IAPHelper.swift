//
//  IAPHelper.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/16/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import StoreKit
import Foundation

public typealias ProductIdentifier = String

 
// Equiv of this somewhere
// THis doesn't work:
let SubScript1: ProductIdentifier = "com.musikyoshi.playtunes.Renewal_1"

// this is the one:
let SubScript2: ProductIdentifier = "Renewal_1"

public typealias ProductsRequestCompletionHandler =
                    (_ success: Bool, _ products: [SKProduct]?) -> Void

class IAPHelper: NSObject {
    
    //typealias ProductsRequestCompletionHandler = (products: [SKProduct]?) -> ()
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    init(prodIds: Set<String>) {
        productIdentifiers = prodIds
        super.init()
    }
}

extension IAPHelper {
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest,
                         didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}


