//
//  OneAvailableInAppPurchaseView.swift
//  FirstStage
//
//  Created by Scott Freshour on 11/7/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import UIKit


class iapPurchaseButton: UIButton {
    var iapID: String = ""
}

class OneAvailableInAppPurchaseView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var instrumentLabel: UILabel!
    @IBOutlet weak var alreadyPurchasedLabel: UILabel!
    
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var chooseBtn: iapPurchaseButton!
    @IBAction func chooseBtnPressed(_ sender: Any) {
    }
}
