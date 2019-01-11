//
//  AppDelegate.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import SwiftyStoreKit

func delay(_ delay:Double, closure:@escaping ()->()){
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var orientationLock = UIInterfaceOrientationMask.portrait
        
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    struct AppUtility {
        static func currOrientation() {
            var currO = UIDevice.current.orientation
            print("\(currO)")
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
        
        /*
        static func lockOrientationToLandscape() {
            let currOrient = UIDevice.current.orientation
            self.lockOrientation(.landscape)
            if !(currOrient == .landscapeLeft || currOrient != .landscapeRight)
                //                {
                ////                self.lockOrientation(.landscape)
                //                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,
                //                                          forKey: "orientation")
                //            } else
                
            { // either support Right Landscape or force it
                //                self.lockOrientation(.landscape)
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,
                                          forKey: "orientation")
            }
        }
        */
        
        static func lockOrientationToLandscape() {
            let currOrient = UIDevice.current.orientation
            self.lockOrientation(.landscape)
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,
                                          forKey: "orientation")
        }
        
        static func lockOrientationToPortrait() {
            self.lockOrientation(.portrait)
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                      forKey: "orientation")
        }
        
        static func unlockOrientation() {
            self.lockOrientation(.all)
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                      forKey: "orientation")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //initialize Settings
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        UserDefaults.standard.register(defaults: [
            Constants.Settings.BPM: 60.0,
            Constants.Settings.AmplitudeThreshold: Float(0.1),
            Constants.Settings.TimingThreshold: 0.2,
            Constants.Settings.FrequencyThreshold: Double(0.03),
            Constants.Settings.Transposition: kTransposeFor_Trumpet,
            Constants.Settings.ShowNoteMarkers: false,
            Constants.Settings.ShowAnalysis: false,
            Constants.Settings.PlayTrumpet: true,
            Constants.Settings.SmallestNoteWidth: Int(30),
            Constants.Settings.SignatureWidth: Int(120),
            Constants.Settings.ScoreMagnification: Int(14)
            ])
        
        let timeIntvls = MK_TimeIntervals()
        UserDefaults.standard.register(defaults: [
            Constants.Settings.UserHopSizeOverride: Int(-12),
            Constants.Settings.UserPeakCountOverride: Int(-12),
            Constants.Settings.UserNoteThresholdOverride: Double(0.0),
            Constants.Settings.UserLatencyOffsetThresholdOverride: Double(0.0),
            Constants.Settings.SubsriptionStatusConfirmed: false,
            Constants.Settings.SubsriptionHasBeenPurchased: false,
            Constants.Settings.ConfirmedSubsExpiryDateAfter1970: Double(0.0),
            Constants.Settings.CheckForAppUpdateInterval: Int(timeIntvls.kMK_1_Month),
            Constants.Settings.LastCheckForAppUpdate: Double(0.0),
            Constants.Settings.StudentInstrument: Int(kInst_Trumpet)
           ])
        
        setCheckForAppUpdateTimeIfFirstRun()
        
        var studentInstrument =
            UserDefaults.standard.integer(forKey: Constants.Settings.StudentInstrument)
        if studentInstrument < kInst_Trumpet || studentInstrument > kInst_Tuba {
            studentInstrument = kInst_Trumpet
        }
        setCurrentStudentInstrument(instrument: studentInstrument)
        PerformanceAnalysisMgr.instance.resetPartialsTable(forInstrument: studentInstrument )

/*
         Constants.Settings.MaxPlayingVolume: Double(0.0),
         Constants.Settings.PlayingVolumeSoundThreshold: Double(0.03),
         Constants.Settings.LastPlayingVolumeCheckDate: Double(0.0),
*/
        
        // hyarhyar   SFAUDIO
        //initialize data
        
        // This line was active in original file:
 //       _ = AVAudioSessionManager.sharedInstance.setupAudioSession()
        
        
        NoteService.initNotes()
        
        let entityName = String(describing: UserAttributes.self)
        let request = NSFetchRequest<UserAttributes>(entityName: entityName)
        let objects = (try? managedObjectContext.fetch(request) as? [UserAttributes])
        if let results = objects {
            if results!.count < 1 {
                initializeUserAttributes()
            }
        }

        // Load the student score data from disk. If first time using app, will create
        // an empty file using the levels/exercises JSON file as the template.
        _ = LessonScheduler.instance.loadScoreFile()
        
        //let lessonScheduler: LessonScheduler? = LessonScheduler.instance
        
        // When the app gets to a point that it needs to set these progressively 
        // "tighter" as the student improves and moves to harder exercises, this 
        // should be moved to the point where the level changes are managed, so 
        // the tables can be rebuilt with progressively less forgiving values.
        var tolerances = pitchAndRhythmTolerances()
        tolerances.setWithInverse( rhythmTolerance:         0.4,
                                   correctPitchPercentage:  0.03,
                                   aBitToVeryPercentage:    0.085,
                                   veryBoundaryPercentage:  0.05 )// Shawn wants a very wide acceptance
        PerformanceAnalysisMgr.instance.rebuildAllAnalysisTables( tolerances )
        
  //      AVAudioSessionManager.sharedInstance.setupAudioSession()
        
        //   Restore when really doing IAP
        PlayTunesIAPProducts.store.requestProducts {
            [weak self] success, products in
            guard let products = products else { return }
            
            PlayTunesIAPProducts.store.products = products
            
            print(products.map {$0.productIdentifier})
            
            for oneSkProd in products {
                if let oneSkProd = oneSkProd as SKProduct? {
                    let currCode = oneSkProd.priceLocale.currencyCode
                    var prodPriceString = ""
                    if oneSkProd.localizedPrice != nil {
                        prodPriceString = oneSkProd.localizedPrice!
                    }
                    let availIapPurchData =
                        AvailableInAppPurchaseData(
                            prodIdentifier:     oneSkProd.productIdentifier,
                            prodDescription:    oneSkProd.localizedDescription,
                            prodTitle:          oneSkProd.localizedTitle,
                            prodPrice:          oneSkProd.price,
                            prodPriceLocale:    oneSkProd.priceLocale,
                            prodPriceStr:       prodPriceString)
                    
                    AvailIapPurchsMgr.sharedInstance.addOneInAppPurchaseData(data: availIapPurchData)
                }
            }
    
            AvailIapPurchsMgr.sharedInstance.printAvailableIAPPurcahasesData()
            
            // If they have previously purchased, and the subs seems to have expired,
            // then we should try to see if the subscription has been updated.
            // But if they've never purchased, then don't scare them off with an
            // insistance to log into iTunes - this might seem suspicious.
            if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown()    &&
               PlayTunesIAPProducts.store.userDefsStoredSubscHasBeenPurchased() &&
               !PlayTunesIAPProducts.store.subscriptionGood() {
                  // If here, then stored info shows previous purchase has expired.
                  // Need to see if it's been updated since last call to verify.
                  PlayTunesIAPProducts.store.verifySubscription() // showAlerts: false)
            }
            
            if let prod1 = products.first  as SKProduct? {
                print("\n-----------------------------------------------")
                print("Product Title:         \(prod1.localizedTitle)")
                print("Product Description:   \(prod1.localizedDescription)")
                print("Product Price:         \(prod1.price)")
                print("Product Price Locale:  \(prod1.priceLocale)")
                print("Product Identifier:    \(prod1.productIdentifier)")
                print("-----------------------------------------------\n")
            }
            print(products.map {$0.productIdentifier})

        }
        
        return true
    }
    
    func initializeUserAttributes() {
        let entity = NSEntityDescription.entity(forEntityName: "UserAttributes", in: managedObjectContext)!
        let userAttributes = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        userAttributes.setValue(1, forKey: "currentLessonNumber")
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        AudioKitManager.sharedInstance.enabledForcedReSetup()
        print("\n   applicationWillResignActive() called\n")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AudioKitManager.sharedInstance.enabledForcedReSetup()
        print("\n   applicationDidEnterBackground() called\n")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("\n   applicationWillEnterForeground() called\n")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("\n   applicationDidBecomeActive() called\n")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        AudioKitManager.sharedInstance.enabledForcedReSetup()
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.musikyoshi.FirstStage" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "FirstStage", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

extension AppDelegate: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        
        queue.finishTransaction(transaction)
//        SubscriptionService.shared.uploadReceipt { (success) in
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
//            }
//        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
//        SubscriptionService.shared.uploadReceipt { (success) in
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
//            }
//        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}
