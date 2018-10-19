//
//  IAPAlerts.swift
//  SwiftyJSON
//
//  Created by Scott Freshour on 10/18/18.
//

import Foundation

/*
 
 Possible states:
 
     ------------------------
     State 1: kSubsState_NoSubs_NoAllAccessEval
         - no subscription
         - have not purchased free all-access eval
 
     ------------------------
     State 2: kSubsState_NoSubs_InAllAccessEval
         - no subscription
         - in all-access eval
 
     ------------------------
     State 3: kSubsState_NoSubs_AllAccessEvalExp
         - no subscription
         - all-acces eval has expired
 
     ------------------------
     State 4: kSubsState_SubsExp
        - have subscribed, but expired

     ------------------------
     State 5: kSubsState_SubsGood
         - have current subscription
 
     ------------------------

*/

let kSubsState_NoSubs_NoAllAccessEval   : Int  = 0
let kSubsState_NoSubs_InAllAccessEval   : Int  = 1
let kSubsState_NoSubs_AllAccessEvalExp  : Int  = 2
let kSubsState_SubsExp                  : Int  = 3
let kSubsState_SubsGood                 : Int  = 4

struct SubscriptionStati {
    var subscriptionGood: Bool
    var subscriptionExpired: Bool        // if true, implies there once was a subscription
    var currInValidAllAccessPeriod: Bool
    var allAccessPeriodExpired: Bool     // if true, implies there once was a purchase
    
    init() {
        self.subscriptionGood            = false
        self.subscriptionExpired         = false
        self.currInValidAllAccessPeriod  = false
        self.allAccessPeriodExpired      = false
    }
}

let subscriptionStati = SubscriptionStati()

func getSubsState() -> Int {
    if subscriptionStati.subscriptionGood {
        return kSubsState_SubsGood
    } else if subscriptionStati.subscriptionExpired {
        return kSubsState_SubsExp
    } else {   // Student has never done a subscription
        if subscriptionStati.currInValidAllAccessPeriod {
            return kSubsState_NoSubs_InAllAccessEval
        } else if subscriptionStati.allAccessPeriodExpired {
            return kSubsState_NoSubs_AllAccessEvalExp
        } else {
            return kSubsState_NoSubs_NoAllAccessEval
        }
    }
}

func displayAlertsBasedOnSubscriptionStatus() {
    let currSubsState = getSubsState()
    switch currSubsState {
         case kSubsState_NoSubs_InAllAccessEval:
            displayNoSubNoAllAccessAlert()
            break;
        case kSubsState_NoSubs_AllAccessEvalExp:
            displayNoSubNoAllAccessAlert()
            break;
        case kSubsState_SubsExp:
            displayNoSubNoAllAccessAlert()
            break;
        case kSubsState_SubsGood:
            displayNoSubNoAllAccessAlert()
            break;
        case kSubsState_NoSubs_NoAllAccessEval: fallthrough
        default:
            displayNoSubNoAllAccessAlert()
    }
}

func displayNoSubNoAllAccessAlert() {
    
}
