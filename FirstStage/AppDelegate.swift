//
//  AppDelegate.swift
//  FirstStage
//
//  Created by David S Reich on 14/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

import UIKit
import CoreData

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
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //initialize Settings
        UserDefaults.standard.register(defaults: [
            Constants.Settings.BPM: 60.0,
            Constants.Settings.AmplitudeThreshold: Float(0.1),
            Constants.Settings.TimingThreshold: 0.2,
            Constants.Settings.FrequencyThreshold: Double(0.03),
            Constants.Settings.Transposition: -2,
            Constants.Settings.ShowNoteMarkers: false,
            Constants.Settings.ShowAnalysis: false,
            Constants.Settings.PlayTrumpet: true,
            Constants.Settings.SmallestNoteWidth: Int(30),
            Constants.Settings.SignatureWidth: Int(60),
            Constants.Settings.ScoreMagnification: Int(14)
            ])
        
        
        //initialize data
        _ = AVAudioSessionManager.sharedInstance.setupAudioSession()
        NoteService.initNotes()
        
        let entityName = String(describing: UserAttributes.self)
        let request = NSFetchRequest<UserAttributes>(entityName: entityName)
        let objects = (try? managedObjectContext.fetch(request) as? [UserAttributes])
        if let results = objects {
            if results!.count < 1 {
                initializeUserAttributes()
            }
        }

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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
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

