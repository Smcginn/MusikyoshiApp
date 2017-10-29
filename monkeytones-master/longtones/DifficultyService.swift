//
//  DifficultyService.swift
//  longtones
//
//  Created by Adam Kinney on 7/3/16.
//  Copyright © 2016 MusiKyoshi, LLC. All rights reserved.
//

import Foundation

struct DifficultyService {
    fileprivate static var difficulties = [Difficulty]()
    
    static func getAllDifficulties() -> [Difficulty] {
        return difficulties;
    }
    
    static func getDifficulty(_ orderId: Int) -> Difficulty? {
        if(orderId > -1)
        {
            let comparisionSet = difficulties.filter{ d in d.orderId == orderId}
            if comparisionSet.count == 1
            {
                return comparisionSet[0]
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    static func getTargetLength(_ orderId: Int, instrument:Instrument) -> Double {
        var length = 0.0

        switch instrument.name! {
        case .flute,.tuba:
            switch orderId {
            case 0:
                length = 2
            case 1:
                length = 4
            case 2:
                length = 7
            case 3:
                length = 10
            case 4:
                length = 15
            case 5:
                length = 25
            case 6:
                length = 25
            default:
                length = 0
            }
        default:
            switch orderId {
            case 0:
                length = 3
            case 1:
                length = 6
            case 2:
                length = 9
            case 3:
                length = 12
            case 4:
                length = 20
            case 5:
                length = 30
            case 6:
                length = 30
            default:
                length = 0
            }
        }
        
        
        
        return length
    }
    
    static func getTargetStarsTimes(_ orderId: Int, instrument:Instrument) -> [Float]
    {
        
        var starsTimes = [Float]()
        
        switch instrument.name! {
        case .flute,.tuba:
            switch orderId {
            case 0:
                starsTimes = [0.3,0.8,1.4,2]
            case 1:
                starsTimes = [0.6,1.6,2.8,4.0]
            case 2:
                starsTimes = [1.05,2.8,4.9,7.0]
            case 3:
                starsTimes = [1.5,4.0,7.0,10.0]
            case 4:
                starsTimes = [2.25,6.0,10.5,15.0]
            case 5:
                starsTimes = [3.75,10.0,17.5,25.0]
            case 6:
                starsTimes = [3.75,10.0,17.5,25.0]
            default:
                break
            }
        default:
            switch orderId {
            case 0:
                starsTimes = [0.45,1.2,2.1,3.0]
            case 1:
                starsTimes = [0.9,2.4,4.2,6.0]
            case 2:
                starsTimes = [1.35,3.6,6.3,9.0]
            case 3:
                starsTimes = [1.8,4.8,8.4,12.0]
            case 4:
                starsTimes = [3.0,8.0,14.0,20.0]
            case 5:
                starsTimes = [4.5,12.0,21.0,30.0]
            case 6:
                starsTimes = [4.5,12.0,21.0,30.0]
            default:
                break
            }
        }

        return starsTimes
    }
    
    static func initDifficulties(){
        difficulties.append(Difficulty(.beginning, 0))
        difficulties.append(Difficulty(.intermediate, 1))
        difficulties.append(Difficulty(.advanced, 2))
        difficulties.append(Difficulty(.expert, 3))
        difficulties.append(Difficulty(.virtuoso, 4))
        difficulties.append(Difficulty(.master, 5))
        difficulties.append(Difficulty(.personalRecord, 6))
        //difficulties.append(Difficulty("Personal Record", 4))
    }

}
