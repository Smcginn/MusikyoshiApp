//
//  IAPHelper.swift
//  FirstStage
//
//  Created by Scott Freshour on 10/16/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//
//  HUGELY based on Ray Wunderlich website tutorial, and also SwiftyStroeKit
//
//  I got almost all the way done with just the Ray Wunderlich (RW) approach, except
//  support for Receipts, Auto-Renewing Subscriptions and Restoring seemed very
//  arbitrary, and in some cases non-existant or incomplete.
//
//  So I tried to switch to SwiftyStoreKit (SSK), starting with just the
//  VerifySubscrtions and Restore code. Got this working in a hybrid environment
//  (some RW, some SSK).
//
//  I then tried to switch completely to SSK, but that was clearly going to take
//  a long time. (As SSK is vdery hard to work with, with lots of ssynchronous
//  code, both approaches are involved and it will take time to appreciate and
//  fully understand how to use *either* approach.)
//
//  So . . . right now this is a crazy hybrid of both.
//
//

import StoreKit
import Foundation
import SwiftyStoreKit

// MOVE TO MISC
extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
    
    func formatDHMS() -> String? {
        let units: NSCalendar.Unit = [.day, .hour, .minute, .second]
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}


extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

public typealias ProductIdentifier = String
let kSKProdNotFound = -1

public typealias ProductsRequestCompletionHandler =
                    (_ success: Bool, _ products: [SKProduct]?) -> Void

enum purchaseState {
    case unknown
    case errorGettingReceipts
    case neverBought
    case expired
    case purchaseGood
}

struct tPurchaseStatus {
    var     state:              purchaseState
    var     confirmed:          Bool
    var     confirmedAttempts:  Int
    var     confirmedDate:      Date
    var     purchaseDate:       Date
    var     expiryDate:         Date
    var     productID:          String
    
    init() {
        self.confirmed          = false
        self.confirmedAttempts  = 0
        self.state              = .unknown
        self.confirmedDate      = Date.distantPast
        self.purchaseDate       = Date.distantPast
        self.expiryDate         = Date.distantPast
        self.productID          = ""
    }
    
    mutating func reset() {
        self.confirmed          = false
        self.confirmedAttempts  = 0
        self.state              = .unknown
        self.confirmedDate      = Date.distantPast
        self.purchaseDate       = Date.distantPast
        self.expiryDate         = Date.distantPast
        self.productID          = ""
    }
//
//    mutating func expiryDateInFuture() -> Bool {
//        let now = Date()
//
//        //let diff1 = now - expiryDate
//
//        let nowSince1970 = now.timeIntervalSince1970
//        let expSince1970 = expiryDate.timeIntervalSince1970
//        let diff2 = nowSince1970 - expSince1970
//
//
//        if now > expiryDate {
//            if confirmed && state == .purchaseGood {
//                // then it expired since last lookup
//                state = .expired
//            }
//            return false
//        } else {
//            return true
//        }
//    }
}

public class IAPHelper: NSObject {
    
    var products: [SKProduct] = []
//    var purchaseStatus = tPurchaseStatus()
//    var backupPurchaseStatus = tPurchaseStatus()

    func backupPurchStatus() {
 //       backupPurchaseStatus = purchaseStatus
    }
    
    func restorePurchStatusFromBackup() {
//        purchaseStatus = backupPurchaseStatus
    }
    
    private let iaphProductIdentifiers: Set<ProductIdentifier>
    private var iaphPurchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    var  confirmedAttempts:  Int = 0

    var doingAnAlert = false

    var respondingToRestoreRequest = false
    
    init(prodIds: Set<String>) {
        iaphProductIdentifiers = prodIds
        print("---------------------------\nPrecessing Product IDs")
        for productIdentifier in prodIds {
            // NOTE!!!  Looks in UserDefaults. Should be somewhere else !
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                iaphPurchasedProductIdentifiers.insert(productIdentifier)
                print("  Previously purchased: \(productIdentifier)")
            } else {
                print("  Not purchased: \(productIdentifier)")
            }
        }
        print("---------------------------")

        super.init()
        
        // make this the payment queue observer
        SKPaymentQueue.default().add(self)
        
        let trans = SKPaymentQueue.default().transactions
        print ("Number outstanding transactions == \(trans.count)")
        print ("yo")
    }
    
    
    // MARK: - Saving / Accessing status in User Defs
    func saveUserDefsSubscStatus(isConfirmed: Bool) {
        UserDefaults.standard.set(
            isConfirmed,
            forKey: Constants.Settings.SubsriptionStatusConfirmed)
    }
    
    func saveUserDefsSubscHasBeenPurchased(hasBeenPurchased: Bool) {
        UserDefaults.standard.set(
            hasBeenPurchased,
            forKey: Constants.Settings.SubsriptionHasBeenPurchased)
    }
    
    func saveUserDefsExpiryDate(expiryDate: Date) {
        let expiryTimeIntSince1970 = expiryDate.timeIntervalSince1970
        
        UserDefaults.standard.set(
            Double(expiryTimeIntSince1970),
            forKey: Constants.Settings.ConfirmedSubsExpiryDateAfter1970)
    }
    
    func setUserDefsExpiryDateToUnknown() {
        let distantPast = Date.distantPast
        let distantPastSince1970 = distantPast.timeIntervalSince1970
        
        UserDefaults.standard.set(
            Double(distantPastSince1970),
            forKey: Constants.Settings.ConfirmedSubsExpiryDateAfter1970)
    }
    
    func userDefsStoredSubscStatusIsKnown() -> Bool {
        let storedSubsStatusIsConfirmed: Bool =
            UserDefaults.standard.bool(forKey: Constants.Settings.SubsriptionStatusConfirmed)
        if storedSubsStatusIsConfirmed {
            return true
        } else {
            return false
        }
    }
    
    func userDefsStoredSubscHasBeenPurchased() -> Bool {
        let storedSubsHasBeenPurchased: Bool =
            UserDefaults.standard.bool(forKey: Constants.Settings.SubsriptionHasBeenPurchased)
        if storedSubsHasBeenPurchased {
            return true
        } else {
            return false
        }
    }
    
    func userDefsStoredSubscIsGoodToGo() -> Bool {
        if userDefsStoredSubscStatusIsKnown() {
            if userDefsStoredSubscHasBeenPurchased() {
                if userDefsStoredSubscIsCurrent() {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else { // nothing has been set in user defs
            return false
        }
    }
    
    
    func userDefsStoredSubscIsCurrent() -> Bool {     // not expired
        let expiryKeyStr = Constants.Settings.ConfirmedSubsExpiryDateAfter1970
        let storedExpiryTimeIntSince1970 = UserDefaults.standard.double(forKey: expiryKeyStr)
        
        let now = Date()
        let nowSince1970 = now.timeIntervalSince1970
        
        let timeDiff = storedExpiryTimeIntSince1970 - nowSince1970
        // if timeDiff > 0 then Expiry date is in the future
        
        if let diffSince1970Str = timeDiff.formatDHMS()
        {
            if timeDiff > 0 {
                print("In subscriptionGood, Good!!  Remaining time: \(diffSince1970Str)")
            } else {
                print("In subscriptionGood, Expired!  Elapsed since expired: \(diffSince1970Str)")
            }
        }
        
        if timeDiff > 0 {
            return true
        } else {
            return false
        }
    }
    
    /*
     func userDefsStoredSubscIsGood() -> Bool {
     let storedSubsStatusIsConfirmed: Bool =
     UserDefaults.standard.bool(forKey: Constants.Settings.SubsriptionStatusConfirmed)
     guard storedSubsStatusIsConfirmed else {
     return false
     }
     
     let storedExpiryTimeIntSince1970 =
     UserDefaults.standard.double(forKey: Constants.Settings.ConfirmedSubsExpiryDateAfter1970)
     
     let value:TimeInterval =  12600.0
     let units: NSCalendar.Unit = [.day, .hour, .minute, .second]
     print("\(value.format(using: [.day, .hour, .minute, .second])!)")
     
     let expirySince1970Str = storedExpiryTimeIntSince1970.format(using: units)
     print("In userDefsStoredSubscIsGood, expirySince1970Str == \(expirySince1970Str)")
     
     let now = Date()
     let nowSince1970 = now.timeIntervalSince1970
     
     let timeDiff = storedExpiryTimeIntSince1970 - nowSince1970
     // if diff2 > 0 then Expiry date is in the future
     
     if timeDiff > 0 {
     return true
     } else {
     return false
     }
     
     if let diffSince1970Str = diffSince1970.formatDHMS()
     {
     if diffSince1970 > 0 {
     print("In subscriptionGood, diffSince1970Str == \(diffSince1970Str)")
     } else {
     print("In subscriptionGood, diffSince1970Str == \(diffSince1970Str)")
     }
     }
     
     }
     */
    
func subscriptionGood() -> Bool {
    
        //        if userDefsStoredSubscIsGood() {
        //            return true
        //        }
        
        //        // For Testing
        //        let now = Date()
        //
        //        //let diff1 = now - expiryDate
        //
        //        let nowSince1970 = now.timeIntervalSince1970
        //        let expSince1970 = expiryDate.timeIntervalSince1970
        //        let diff2 = expSince1970 - nowSince1970
        //
        
        //        let expirySince1970Str = expSince1970.formatDHMS()
        //        print("In subscriptionGood, expirySince1970Str == \(expirySince1970Str)")
        //        let nowSince1970Str    = nowSince1970.formatDHMS()
        //        let diffSince1970 = expSince1970 - nowSince1970
        //        if let diffSince1970Str = diffSince1970.formatDHMS()
        //        {
        //            if diffSince1970 > 0 {
        //                print("In subscriptionGood, diffSince1970Str == \(diffSince1970Str)")
        //            } else {
        //                print("In subscriptionGood, diffSince1970Str == \(diffSince1970Str)")
        //            }
        //        }
        
        // if diff2 > 0 then Expiry date is in the future
        
        //////////////////////////////////
        
        return userDefsStoredSubscIsGoodToGo()   // IAPSUBS
        
        /*
         
         if userDefsStoredSubscIsGood() {
         return true
         }
         
         if confirmed &&
         state == .purchaseGood &&
         expiryDateInFuture() {
         return true
         } else {
         return false
         }
         */
    }
}

extension IAPHelper {
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: iaphProductIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return iaphPurchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases() {
        self.respondingToRestoreRequest = false
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            var didAtLeastOneRestore = false
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                //HEY  We End Up Here when a successful restore has happened   !!!!
                print("\n\n\n     SSK Restore WORKED!!!!!!!   \n\n\n")
                
                for oneResult in results.restoredPurchases {
                    print ("One Successful Result:")
                    print ("  \(oneResult)\n")
                }
                
                let numRestored = results.restoredPurchases.count
                if numRestored > 0 {
                    didAtLeastOneRestore = true
//                    let mostRecentItem = results.first
//                    if let orgPurchDate = mostRecentItem?.originalPurchaseDate {
//                        print ("  Most Recent Purchase, Purchase Date: \(orgPurchDate)")
//                        self.purchaseStatus.purchaseDate = orgPurchDate
//                    }
//                    if let expiryDate = mostRecentItem?.subscriptionExpirationDate {
//                        print ("  Most Recent Purchase, Expiration Date: \(expiryDate) \n")
//                        self.purchaseStatus.expiryDate = expiryDate
//                    }
//
//
//
//                    print ("-------------------------------\nRestoredPurchases")
//                    var numToDo = numRestored
//                    if numToDo > 3
//                        numToDo = 3
//                    for i in 0...numToDo-1 {
//                        print ("   For RestoredPurchase #\(i)")
//                        let onePurch = results.restoredPurchases[i]
//                        onePurch.transaction.
//                        onePurch.transaction.transactionDate
//                        onePurch.transaction.transactionDate
//                    }
                }
                
                if didAtLeastOneRestore {
                    self.respondingToRestoreRequest = true
                    PlayTunesIAPProducts.store.verifySubscription()
                }
                
                let now = Date()
                print("\n  Now =   \(now)  \n")
                
                for oneRestPurch in results.restoredPurchases {
                    print("\n----------------------------------------------------------------------")
                    print("One Restored Purchase: \(oneRestPurch)")
                }
                print("--------------------------------------------------------------------------")

//                print("Restore Success: \(results.restoredPurchases)")
                print("\n\n\n")
            }
            else {
                // DOANALERTHERE
                print("Nothing to Restore")
            }
        }
        
        // TODO   DOANALERTHERE
        // if restoredItems > 0
        //     set a global that just did a restore
        //     verifySubs
        //     In verifySubs, if doingRestore global set, at end pop up alert to say if
        //              anything was actually restored or not.
        //
        
        //SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func getProductIndex(prodID: String) -> Int {
        var index = 0
        for onSKProd in products {
            if onSKProd.productIdentifier == prodID {
                return index
            }
            index += 1
        }
        return kSKProdNotFound
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest,
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

let kSharedSecret = "514965e34b3d45d3ae8bb32398ea0782"

extension IAPHelper {
    
    func verifySubscription(showAlerts: Bool = true) {
        let appleValidator = AppleReceiptValidator(service: .production,
                                                   sharedSecret: kSharedSecret)
//        backupPurchStatus()
//        backupPurchaseStatus.reset()
        
        print("\n\n\n\n     Going to request Receipt Data\n\n\n\n")
        
        let requestTime = Date()

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
                
            let elapsed = abs(requestTime.timeIntervalSinceNow)
            print ("Elapsed time to get reciept: \(elapsed) seconds")
            
            switch result {
                case .success(let receipt):
                    var productIds: Set<ProductIdentifier>
                    
                 productIds =  kUsingSubScript_1W_toss ?   [SubScript_1W_toss,
                                                            SubScript_1Y,
                                                            SubScript_6M,
                                                            SubScript_1M]
                                                       :   [SubScript_1Y,
                                                            SubScript_6M,
                                                            SubScript_1M]
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    self.saveUserDefsSubscStatus(isConfirmed: true)
                    self.saveUserDefsSubscHasBeenPurchased(hasBeenPurchased: true)

//                    self.purchaseStatus.state = .purchaseGood
                    
                    print("\n----------------------------------------------------------")
                    print("\nValid Product\n")
                    
                    print("\n  Number of Valid Products:  \(items.count)  \n")

                    let now = Date()
                    print("\n  Now =   \(now)  \n")

                    let mostRecentItem = items.first
                    if let orgPurchDate = mostRecentItem?.originalPurchaseDate {
                        print ("  Most Recent Purchase, Purchase Date:   \(orgPurchDate)")
//                        self.purchaseStatus.purchaseDate = orgPurchDate
                    }
                    if let expiryDate = mostRecentItem?.subscriptionExpirationDate {
                        print ("  Most Recent Purchase, Expiration Date: \(expiryDate) \n")
//                        self.purchaseStatus.expiryDate = expiryDate
                        self.saveUserDefsExpiryDate(expiryDate: expiryDate)
                    } else {
                        itsBad()
                        self.setUserDefsExpiryDateToUnknown()
                    }
                    
                    print("\(productIds) are valid until \(expiryDate)\n")
                    for oneItem in items {
                        print("  ------------------------------------------")
                        let orgPurchDt = oneItem.originalPurchaseDate
                        print ("      One Item, Purchase Date:   \(String(describing: orgPurchDt))")
                        
                        let expiryDt = oneItem.subscriptionExpirationDate
                        print ("      One Item,, Expiration Date: \(String(describing: expiryDt)) \n")
                    }
                    print("  ------------------------------------------")
                    
                    
    //                print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                    print("----------------------------------------------------------\n")
//                    self.purchaseStatus.state = .purchaseGood
//                    self.purchaseStatus.confirmed = true
//                    self.purchaseStatus.confirmedDate = Date()
                    
                    if self.respondingToRestoreRequest {
                        displayRestoreStatusAlert(result: .successful)
                        self.respondingToRestoreRequest = false
                    }
                    
                case .expired(let expiryDate, let items):
                    self.saveUserDefsSubscStatus(isConfirmed: true)
                    self.saveUserDefsSubscHasBeenPurchased(hasBeenPurchased: true)
                    
//                    self.purchaseStatus.state = .expired
                    print("\n----------------------------------------------------------")
                     print("\nExpired Products:  \n")
                    
                    print("\n  Number of nExpired Products:  \(items.count)  \n")
                    
                    let now = Date()
                    print("\n  Now =   \(now)  \n")

                    let mostRecentItem = items.first
                    if let orgPurchDate = mostRecentItem?.originalPurchaseDate {
                        print ("  Most Recent Purchase, Purchase Date:   \(orgPurchDate)")
//                        self.purchaseStatus.purchaseDate = orgPurchDate
                    }
                    if let expiryDate = mostRecentItem?.subscriptionExpirationDate {
                        print ("  Most Recent Purchase, Expiration Date: \(expiryDate) \n")
  //                      self.purchaseStatus.expiryDate = expiryDate
                        self.saveUserDefsExpiryDate(expiryDate: expiryDate)
                    } else {
                        itsBad()
                        self.setUserDefsExpiryDateToUnknown()
                    }
                    
   //                 print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                    print("----------------------------------------------------------\n")
//                    self.purchaseStatus.state = .expired
//                    self.purchaseStatus.confirmed = true
//                    self.purchaseStatus.confirmedDate = Date()
                    
                    if self.respondingToRestoreRequest {
                        displayRestoreStatusAlert(result: .expired)
                        self.respondingToRestoreRequest = false
                    }

               case .notPurchased:
                    self.saveUserDefsSubscStatus(isConfirmed: true)
                    self.saveUserDefsSubscHasBeenPurchased(hasBeenPurchased: false)
                    self.setUserDefsExpiryDateToUnknown()
                    
 //                   self.purchaseStatus.state = .neverBought
                    print("\n----------------------------------------------------------")
                    print("\nNever-Purchased Products:  \n")
                    print("The user has never purchased \(productIds)")
                    print("----------------------------------------------------------\n")
//                    self.purchaseStatus.state = .neverBought
//                    self.purchaseStatus.confirmed = true
//                    self.purchaseStatus.confirmedDate = Date()
                    
                    if self.respondingToRestoreRequest {
                        displayRestoreStatusAlert(result: .notFound)
                        self.respondingToRestoreRequest = false
                    }
                    
                } // switch purchaseResult (inner switch)
                
            case .error(let error):
                
                self.restorePurchStatusFromBackup()
//                self.purchaseStatus.state = .errorGettingReceipts
                print("Receipt verification failed: \(error)")
                
                if showAlerts {
    //                let titleString = "Unable to get Subscription Data from iTunes"
                    
                    // FIXME - figure out how to get the text I'm looking for, localized
//                    var errString = "\(error)"
//                    if errString.contains("annot connect to iTunes") {
//                        errString = "Cannot connect to iTunes Store"
//                    } else {
//                        errString = "Network error"
//                    }
//
                    let errString = "\(error)"
                    var titleString = ""
                    if errString.contains("annot connect to iTunes") {
                        titleString = "Cannot connect to iTunes Store"
                    } else {
                        titleString = "Network error"
                    }
                    
                    var msgStr = "\nPlayTunes cannot verify if you have a valid subscription, "
                    msgStr += "because we are unable to get Subscription Data from iTunes.\n\n"
                    msgStr += "You can always access the first two Levels in PlayTunes for free! And you are not required to be signed in to iTunes.\n\n"
                    msgStr += "If you want to explore the upper Levels, you will need a verifiable subscription to Playtunes."
                    
                    
    //                if let err = error as NSError?,
    //                    let localizedDescription = error.localizedDescription {
    //                    errString = localizedDescription
    //                }
                    displayErrorAlert(titleStr: titleString, errStr: msgStr)
                }
                
                if self.respondingToRestoreRequest {
                    displayRestoreStatusAlert(result: .networkError)
                    self.respondingToRestoreRequest = false
                }
                
            } // switch result
            
            print("\n\n\n\n     Receipt Data received and processed \n\n\n\n")
        }
    }
}

enum restoreResult {
    case successful
    case expired
    case notFound
    case networkError
}

func displayRestoreStatusAlert(result: restoreResult) {
    var titleStr = "Restore Completed"
    var msg = ""
    switch result {
    case .successful:
        msg =  "\nValid Subscription found and restored\n"
        msg += "You are good to go!\n"
    case .expired:
        titleStr = "Attempt to Restore Completed"
        msg =  "\nYour last Valid Subscription \ncannot be Restored \nbecause it has expired\n"
    case .notFound:
        titleStr = "Attempt to Restore Completed"
        msg =  "\nNo Previous Subscription purchases were found\n"
    case .networkError:
        titleStr =  "\nNetwork error\n"
        msg = "\nUnable to contact iTunes\n"
        msg += "\nPlease try again later\n"
    }
    let alertController = UIAlertController(title: titleStr, message: msg, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    alertController.show(animated: true, completion: nil )
}

func displayErrorAlert(titleStr: String, errStr: String) {
    
//    var  localizedDescr = ""
//    if let transactionError = transaction.error as NSError?,
//        let localizedDescription = transaction.error?.localizedDescription { //,
//        //transactionError.code != SKError.paymentCancelled.rawValue {
//        localizedDescr = localizedDescription
//        print("Transaction Error: \(localizedDescription)")
//    }
    
    var msg = "\n"
    if errStr.isNotEmpty {
        msg += errStr
    }
    msg += "\n\n Please try Again in a while.\n"
    
    let alertController = UIAlertController(title: titleStr, message: msg, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
    alertController.show(animated: true, completion: nil )
}

extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue,
                             updatedTransactions transactions: [SKPaymentTransaction]) {
        print("In func paymentQueue")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("In func complete")
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
//        let alertController = UIAlertController(title: "Completed, dude", message: "<Alert Message>", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
//        alertController.show(animated: true,  completion: nil )

    }
    
    private func restore(transaction: SKPaymentTransaction) {
        print("In func restore")
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("    (in func restore,  for \(productIdentifier) )")

        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        
//        if !doingAnAlert {
//            doingAnAlert = true
//            let titleStr = "Restore of Any Previous Purchases Completed Successfully"
//            let msg = "\n\nWill now verify if they are current or expired\n"
//            let alertController = UIAlertController(title: titleStr, message: msg, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
//            alertController.show(animated: true,  completion: {
//                self.doingAnAlert = false
//            })
//        }
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("In func fail")
        print("fail...")
        var  localizedDescr = ""
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription { //,
            //transactionError.code != SKError.paymentCancelled.rawValue {
            localizedDescr = localizedDescription
            print("Transaction Error: \(localizedDescription)")
        }
        
        var msg = "\n"
        if localizedDescr.isNotEmpty {
            msg += localizedDescr
        }
        msg = "\nTry Again in a while.\n"

        let alertController = UIAlertController(title: "Failed Transaction", message: "\n\nUnable to complete the transaction.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
          alertController.show(animated: true, completion: nil )
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        print("In func deliverPurchaseNotificationFor,  for \(String(describing: identifier))")
        
        iaphPurchasedProductIdentifiers.insert(identifier)
        
        // NOTE!!!  Stores in UserDefaults. Should be somewhere else !
        UserDefaults.standard.set(true, forKey: identifier)
        
        print("Going to post a Notification,  for \(String(describing: identifier))")
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}
