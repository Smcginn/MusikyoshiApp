//
//  InAppPurchasesViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/7/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class InAppPurchasesViewController: UIViewController {

    @IBOutlet weak var iapScrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentView: UIView!
    
    @IBOutlet weak var scrollViewContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var oneIAPPurchViews: [OneAvailableInAppPurchaseView?] = []

    let oneVwHt = CGFloat(402)
    let oneVwWd = CGFloat(314)
    
    let contentTopBottomSpacing: CGFloat = 15.0
    let contentHtSpacing: CGFloat = 25.0
    
    var contentHt: CGFloat = 0.0
    
    var iapDescrTextJson: JSON?
    var iapjsonFileLoaded = false

    var userDidABuyOrRestore = false
    
    func returnHandler(_ act: UIAlertAction) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func presentNoEntriesAlert() {
        
        
        let titleStr = "No Purchase Options Found"
        var msgStr = "\n\nThere was a problem contacting Apple for the In-App Purchases\n\n"
        msgStr += "Please wait a bit and try again\n"
        
        let ac = MyUIAlertController(title: titleStr,
                                     message: msgStr,
                                     preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK",  style: .default, handler: returnHandler))
        ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor

        self.present(ac, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // self.view.backgroundColor = kDarkSkyBlue
        // iapScrollView.backgroundColor = kDarkSkyBlue
         contentHt = contentTopBottomSpacing

        let numIAPEntries = AvailIapPurchsMgr.sharedInstance.numIAPEntries()
        
        if numIAPEntries <= 0 {
            presentNoEntriesAlert()
            return
        }
        
        if DeviceType.IS_IPHONE_5orSE {
            titleLabel.font = UIFont(name: "Futura-Bold", size: 27.0)
        }
        
        if numIAPEntries > 0 {
        
            for idx in 0..<numIAPEntries {
                if let oneIAPPurchView =
                    Bundle.main.loadNibNamed("OneAvailableInAppPurchaseView",
                                             owner: self,
                                             options: nil)?.first as? OneAvailableInAppPurchaseView {
                //if oneIAPPurchView != nil {
//                    var currSz = oneIAPPurchView.frame.size
//                    var superSz = super.view.frame.size
                    
                    //oneIAPPurchView.frame.size.height = oneVwHt
                    oneIAPPurchView.translatesAutoresizingMaskIntoConstraints = false
                    // oneIAPPurchView.frame.size.width  = view.frame.width * 0.4
                    
                    oneIAPPurchView.layoutIfNeeded()
 //                   let radiiSize: CGSize = CGSize(width:12.0, height:8.0)
                    oneIAPPurchView.backgroundColor = (.greyColor)
                    scrollViewContentView.addSubview(oneIAPPurchView)
                    
//                    currSz = oneIAPPurchView.frame.size
//                    let currBds = oneIAPPurchView.bounds
                    
                    contentHt += oneIAPPurchView.frame.size.height
                    oneIAPPurchView.overviewLabel.numberOfLines = 0
                    // oneIAPPurchView.layer.borderColor = (UIColor.gray).cgColor
                    // oneIAPPurchView.layer.borderWidth = 1.0
                    oneIAPPurchView.chooseBtn.addTarget(
                        self,
                        action: #selector(InAppPurchasesViewController.iapChooseBtnPressed),
                        for: .touchUpInside)

                    oneIAPPurchView.restoreButton.addTarget(
                        self,
                        action: #selector(InAppPurchasesViewController.iapRestoreBtnPressed),
                        for: .touchUpInside)
                    
                    // so that popup alerts can access correct IAP data:
                    oneIAPPurchView.chooseBtn.tag = idx
                    oneIAPPurchView.restoreButton.tag = idx

                    oneIAPPurchViews.append(oneIAPPurchView)
                }
               //  num += 1
            } // while num < numIAPEntries
        }

        if numIAPEntries > 0 {
            for i in 0...oneIAPPurchViews.count-1 {
                fillIAPPurchViewWithText( knownEntryIdx: i, purchView: oneIAPPurchViews[i])
            }
        }
        
        contentHt += contentTopBottomSpacing
        
//        let currContentWd = iapScrollView.frame.size.width
//        let contentSz = CGSize(width: currContentWd, height: contentHt)
//        iapScrollView.contentSize = contentSz

        // Do any additional setup after loading the view.
        
        if numIAPEntries > 0 {
            
            let prodIDStr = AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: 0)
            let extraText = getExtraTextForID( inAppPurchID: prodIDStr )
            print("===== ===== ===== ===== =====")
            print("  \(extraText.title)")
            print("  \(extraText.language)")
            print("  \(extraText.instrument)")
            print("  \(extraText.overview)")
            print("===== ===== ===== ===== =====")
        }
    }

    func fillIAPPurchViewWithText( knownEntryIdx: Int,
                                   purchView: OneAvailableInAppPurchaseView?) {
        guard purchView != nil else { return }
        
        let numIAPEntries = AvailIapPurchsMgr.sharedInstance.numIAPEntries()
        guard knownEntryIdx >= 0 && knownEntryIdx < numIAPEntries else {
            return
        }
        
        let prodIDStr = AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: knownEntryIdx)
        
        // get the data needed from the known entries JSON file
        let extraText = getExtraTextForID( inAppPurchID: prodIDStr )
        
        // get the data needed from the Apple downloaded data
        let priceText = AvailIapPurchsMgr.sharedInstance.getPriceForEntry(idx: knownEntryIdx)
        
        purchView!.titleLabel.text      = extraText.title
        purchView!.overviewLabel.text   = extraText.overview
        purchView!.languageLabel.text   = extraText.language
        purchView!.instrumentLabel.text = extraText.instrument
        purchView!.priceLabel.text      = priceText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PlayTunesIAPProducts.store.userDefsStoredSubscStatusIsKnown() &&
            PlayTunesIAPProducts.store.userDefsStoredSubscIsGoodToGo() {
            let titleStr = "You Have Already Purchased PlayTunes"
            var msgStr = "\n\nYou have a current vaild subscription."
            msgStr += "\n\nYou Are Good To Go!\n\n"
            let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default,
                                       handler: alreadyPurchasedHandler))
            self.present(ac, animated: true, completion: nil)
        } else {
            let numDays = daysUntilFreePeriodEndDate()
            if numDays > 4 {
                showDontNeedToPurchaserAlert(parentVC: self)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.title = "Purchase Options"
        
        // Trying to set some of the size, spacing, and other layout aspects of the
        // dynamically loaded-by-nib views doesn't work unless those actions are
        // deferred until after AutoLayout has done its thing. Hence this stuff here.
        
        var contentViewHeight: CGFloat = 0
        let spacing: CGFloat = 40
        
        var index = 0
        for oneIAPPurchView in oneIAPPurchViews {
             // oneIAPPurchView!.frame.origin.y = contentHt
            // oneIAPPurchView!.frame.size.height = oneVwHt
            // oneIAPPurchView!.frame.size.width  = view.frame.width * 0.4
             oneIAPPurchView!.centerXAnchor.constraint(equalTo: scrollViewContentView.centerXAnchor).isActive = true
            
            if index >= 1 {
                oneIAPPurchView!.topAnchor.constraint(equalTo: oneIAPPurchViews[index-1]!.bottomAnchor, constant: spacing).isActive = true
            } else {
                oneIAPPurchView!.topAnchor.constraint(equalTo: scrollViewContentView.topAnchor).isActive = true
            }
            
            let radiiSize: CGSize = CGSize(width:12.0, height:18.0)
            oneIAPPurchView!.roundedView(radiiSz: radiiSize)
            contentViewHeight += oneIAPPurchView!.frame.size.height
            
            let prodIDStr = AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: index)
            useThisToSuppressWarnings(str: "\(prodIDStr)")

            if !IAPHelper.canMakePayments() {
                oneIAPPurchView!.chooseBtn.isHidden = true
                oneIAPPurchView!.alreadyPurchasedLabel.isHidden = false
                oneIAPPurchView!.alreadyPurchasedLabel.text = "Not Available"
            } else {
                oneIAPPurchView!.chooseBtn.isHidden = false
                oneIAPPurchView!.alreadyPurchasedLabel.isHidden = true
            }
            
            //            // ovsrride for temp testing
            //            if index % 2 == 0 {
            //                oneIAPPurchView!.chooseBtn.isHidden = true
            //                oneIAPPurchView!.alreadyPurchasedLabel.isHidden = false
            //            } else {
            //                oneIAPPurchView!.chooseBtn.isHidden = false
            //                oneIAPPurchView!.alreadyPurchasedLabel.isHidden = true
            //            }
            
            index += 1
        }
        
        contentViewHeight += spacing + 20 // 20 for bottom
        scrollViewContentViewHeightConstraint.constant = contentViewHeight
        
        
//        let currContentWd = iapScrollView.frame.size.width
//        let contentSz = CGSize(width: currContentWd, height: contentHt)
//        iapScrollView.contentSize = contentSz
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if userDidABuyOrRestore { // then put getting-updated-receipts in motion
            PlayTunesIAPProducts.store.verifySubscription()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    var wantToBuyEntryIndex = 0
    var wantToRestoreEntryIndex = 0

    
    var purchaseTitleText = ""
    var descriptionText = ""
    var subsPriceText = ""
    var durationText = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //self.title = ""
        
        if segue.identifier == kshowAUtoRenewDetailsSegueID {
            if let destination = segue.destination as? AutoRenewNotificationViewController {
                
                subsPriceText = AvailIapPurchsMgr.sharedInstance.getPriceForEntry(idx: wantToBuyEntryIndex)
                purchaseTitleText = AvailIapPurchsMgr.sharedInstance.getProdTitleForEntry(idx: wantToBuyEntryIndex)
                descriptionText = AvailIapPurchsMgr.sharedInstance.getProdDescriptionForEntry(idx: wantToBuyEntryIndex)
                
                let prodIDStr = AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: wantToBuyEntryIndex)
                let extraText = getExtraTextForID( inAppPurchID: prodIDStr )
                durationText = extraText.title // this title is the subs duration

                /*
                // DELETE THIS LATER:
                if wantToBuyEntryIndex == 0  {
                    subsPriceText = "Free"
                    purchaseTitleText = "Trumpet, All Levels, 2-Week Trial"
                    descriptionText = "2-Week All-Level Access, English Videos"
                    durationText = "2 Weeks"
                }
                */

                destination.purchaseTitleText = purchaseTitleText
                destination.descriptionText = descriptionText
                destination.subsPriceText = subsPriceText
                destination.durationText = durationText
            }
        }
    }
    
    let kshowAUtoRenewDetailsSegueID = "showAUtoRenewDetailsSegue"
    
    // This is the return from the AutoRenewNotification VC.
    @IBAction func unwindToInAppPurchasesVC(segue: UIStoryboardSegue) {
         if let autoRenewNotifVC = segue.source as? AutoRenewNotificationViewController {
            if autoRenewNotifVC.userPressedPurchase {
                doThePurchase()
            }
        }
    }
    
    func doThePurchase() {
        
        let prodIDStr =
            AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: wantToBuyEntryIndex)
        
        // Get the SKProduct from the saved products retrieved from Apple
        let skProdIndex = PlayTunesIAPProducts.store.getProductIndex(prodID: prodIDStr)
        if skProdIndex != kSKProdNotFound {
            let skProd = PlayTunesIAPProducts.store.products[skProdIndex]
            
            print("\n-----------------------------------------------")
            print("Going to buy the following: ")
            print("  Product Title:         \(skProd.localizedTitle)")
            print("  Product Description:   \(skProd.localizedDescription)")
            print("  Product Price:         \(skProd.price)")
            print("  Product Price Locale:  \(skProd.priceLocale)")
            print("  Product Identifier:    \(skProd.productIdentifier)")
            print("-----------------------------------------------\n")
            
            userDidABuyOrRestore = true
 //           PlayTunesIAPProducts.store.purchaseStatus.reset()
            
            // Buy it
            PlayTunesIAPProducts.store.buyProduct(skProd)
        }
    }
 
    @objc func iapChooseBtnPressed(sender: iapPurchaseButton) {
        print("ChooseBtnPressed called")
        
        let iapID = sender.tag
        wantToBuyEntryIndex = iapID
        
        self.performSegue(withIdentifier: kshowAUtoRenewDetailsSegueID,
                          sender: self)
    }

    @IBAction func restoreBtnPressed(_ sender: Any) {
        PlayTunesIAPProducts.store.restorePurchases()
        presentRestoreInProgressAlert()
        
//       userDidABuyOrRestore = true
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func presentRestoreInProgressAlert() {
        let titleStr = "Restore In Progress"
        let msgStr = "\n\nThis may take a few seconds . . .\n\n"
        //msgStr += "\n\nYou Are Good To Go!\n\n"
        let ac = MyUIAlertController(title: titleStr, message: msgStr, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default,
                                   handler: alreadyPurchasedHandler))
        self.present(ac, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            ac.dismiss(animated: true, completion: nil)
        }
//        close(alert: ac, after: 2.0)
    }
    
//    @IBAction func aBasicMessageAlert(sender: AnyObject) {
//        let sweetAlert = SweetAlert().showAlert("Here's a message!")
//
//        close(sweetAlert, after: 2.0)
//    }
    
    
//    func close(alert: MyUIAlertController, after seconds: Double) {
//        Timer.scheduledTimerWithTimeInterval(seconds,
//                                               target: self,
//                                               selector: #selector(closeAlert),
//                                               userInfo: ["alert": alert],
//                                               repeats: true)
//    }
//
//    func closeAlert(timer: Timer) {
//        if let alert = timer.userInfo!["alert"] as? MyUIAlertController
//        {
//            let dummyCloseButton = UIButton()
//            dummyCloseButton.tag = 0
//            alert.pressed(dummyCloseButton)
//        }
//    }
    
    
    @objc func iapRestoreBtnPressed(sender: iapPurchaseButton) {

        PlayTunesIAPProducts.store.restorePurchases()
        userDidABuyOrRestore = true

        let iapID = sender.tag
        wantToRestoreEntryIndex = iapID
        let prodIDStr = AvailIapPurchsMgr.sharedInstance.getProductIDForEntry(idx: iapID)
        print("RestoreBtnPressed called for \(prodIDStr)")
    }
    
    func alreadyPurchasedHandler(_ act: UIAlertAction) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    typealias tIapExtraText = (title: String, overview: String, language: String, instrument: String)
    let kEmptyIapExtraText: tIapExtraText = ("<NOT FOUND>", "<NOT FOUND>", "<NOT FOUND>", "<NOT FOUND>")

    // MARK: - - funcs to deal with JSON supporting text file
    
    func loadIAPDescrTextJsonFile() -> Bool {
        guard !iapjsonFileLoaded else { return true }
        
        if let file = Bundle.main.path( forResource: "InAppPurchasesDescritopnText",
                                        ofType: "json" ) {
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: file))
            if jsonData != nil {
                iapDescrTextJson = try? JSON(data: jsonData!)
                if iapDescrTextJson != nil {
                    iapjsonFileLoaded = true
                    print ("acquired iapDescrTextJson!")
                } else {
                    print ("unable to acquire iapDescrTextJson")
                }
            } else {
                print ("unable to acquire iapDescrTextJson")
            }
        } else {
            print("Invalid InAppPurchasesDescritopnText filename/path.")
        }
        
        return iapjsonFileLoaded
    }
    
    
    func getExtraTextForID( inAppPurchID: String ) -> tIapExtraText {
        if !iapjsonFileLoaded { // first time, or error last time
            _ = loadIAPDescrTextJsonFile()
        }
        guard iapjsonFileLoaded else { return kEmptyIapExtraText }
        
        var iapExtraText: tIapExtraText = kEmptyIapExtraText
        
        if let onePurtchOptDataJson = findJsonNodeForID(prodID: inAppPurchID) {
            let titleStr = onePurtchOptDataJson["Title"].string
            if titleStr != nil {
                iapExtraText.title = titleStr!
            }
            
            let langStr = onePurtchOptDataJson["Language"].string
            if langStr != nil {
                iapExtraText.language = langStr!
            }
            
            let instStr = onePurtchOptDataJson["Instrument"].string
            if instStr != nil {
                iapExtraText.instrument = instStr!
            }
            
            var overviewText = ""
            let count = onePurtchOptDataJson["OverviewText"].count
            for idx in 0...count-1 {
                // let titleStr = levelsJson?[section]["title"].string
                if let oneStr = onePurtchOptDataJson["OverviewText"][idx]["oneLine"].string {
                    overviewText += oneStr
                }
            }
            iapExtraText.overview = overviewText
        }
        
        return iapExtraText
    }
    
    func findJsonNodeForID(prodID: String) -> JSON? {
        var foundNode: JSON? = nil
        
        if let knownPurchOptsJson = iapDescrTextJson?["knownIapPurchaseOptions"] {
            let count = knownPurchOptsJson.count
            for i in 0...count {
                let onePurchOptsJson: JSON? = knownPurchOptsJson[i]
                if onePurchOptsJson != nil {
                    let thisID = onePurchOptsJson!["ProductID"].string
                    if thisID == prodID {
                        foundNode = onePurchOptsJson
                        break
                    }
                }
            }
        }
        return foundNode
    }
}

func showDontNeedToPurchaserAlert(parentVC: UIViewController) {   // JUNE15_2  JULY07 AUGUST1
    let numDays = daysUntilFreePeriodEndDate()
    // let titleStr = "Use PlayTunes for Free until June 15, 2020!\n\n\(numDays) days remaining - Enjoy!"
    let titleStr = "Use PlayTunes for Free until August 1, 2020"
//    let msgStr = "\nAfter June 15, 2020, you will have purchase options if you wish to continue. Please visit the App Store in June for more info. (Your use of PlayTunes now does not commit you in any way to purchasing.)"
    
    //  JULY07 AUGUST1
    let msgStr = "\nYou don't need to purchase a subscription until after August 1, 2020 - you have \(numDays) days remaining for Free All-Level access.\n\nBut if you are enjoying PlayTunes and wish to continue using it, here are the subscriptions we offer."
    
    let ac = MyUIAlertController(title: titleStr,
                                 message: msgStr,
                                 preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK",
                               style: .default,
                               handler: nil))
    ac.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = kDefault_AlertBackgroundColor
    
    parentVC.present(ac, animated: true, completion: nil)
}

