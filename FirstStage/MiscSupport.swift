//
//  MiscSupport.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/30/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

extension UIButton {
    func roundedButton() {
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: .allCorners,
                                     cornerRadii:CGSize(width:8.0, height:8.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}

func createAttributedText(str: String, fontSize: CGFloat) -> NSMutableAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center
    let retAttrStr =
        NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedStringKey.font:UIFont( name: "Marker Felt",
                                                   size: fontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.foregroundColor : UIColor.yellow] )
    if retAttrStr.length == 0 {
        print ("Unable to create NSMutableAttributedString in createAttributedText()")
    }
    
    return retAttrStr
}

// verison with color
func createAttributedText(str: String, fontSize: CGFloat, color: UIColor) -> NSMutableAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center
    let retAttrStr =
        NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedStringKey.font:UIFont( name: "Marker Felt",
                                                   size: fontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.foregroundColor : color] )
    if retAttrStr.length == 0 {
        print ("Unable to create NSMutableAttributedString in createAttributedText()")
    }
    
    return retAttrStr
}

// NSForegroundColorAttributeName : color



// MARK: - for debugging and robustness

func itsBad() {
    print ("It's Bad")
}

func ASSUME(_ testThis: Bool) -> Bool {
    if testThis {
        return true
    } else {
        itsBad()
        return false
    }
}

//
//   use:   let gold = UIColor(hexString: "#ffe700ff")
//
extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}


extension UIDevice {
    public var is_iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

func platform() -> String {
    var size = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0,  count: size)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
}

func isiPhoneSE() -> Bool {
    let plat = platform()
    if plat == "iPhone8,4" {
        return true
    } else {
        return false
    }
}

// Double, Int, UInt
class percentSliderVar<T: Comparable> {
    let lowerVal: T
    let upperVal: T
    
    // This is the most forgiving setting possible for this variable
    let minSliderVal: T
    
    // This is the least forgiving setting possible for this variable
    let maxSliderVal: T

    // must be 1-100.  This is the percentage between minSliderVal and maxSliderVal
    var sliderSetting: Int
    func setSliderSetting(newSetting: Int) {
        _ = ASSUME( newSetting >= 1 && newSetting <= 100 )
        sliderSetting   = newSetting
    }
    
    var currVal: T
    
    init( low: T, high: T, minSlider: T, maxSlider: T) {
        _ = ASSUME( low < high )
        _ = ASSUME( minSlider < maxSlider )
        _ = ASSUME( low >= minSlider )
        _ = ASSUME( maxSlider <= high )

        lowerVal        = low
        upperVal        = high
        minSliderVal    = minSlider
        maxSliderVal    = maxSlider
        
        sliderSetting   = 50
        currVal = minSliderVal
    }
}

class percentSlideDoubleVar: percentSliderVar<Double> {
    func setSlider(newSetting: Int) {
        _ = ASSUME( newSetting >= 1 && newSetting <= 100 )
        super.setSliderSetting(newSetting: newSetting)
        
        let percent: Double = Double(sliderSetting/100)
        let diff: Double = (maxSliderVal - minSliderVal)
        let percentDiff = diff * percent
        currVal = minSliderVal + percentDiff
    }
}

class percentSlideIntVar: percentSliderVar<Int> {
	func setSlider(newSetting: Int) {
        _ = ASSUME( newSetting >= 1 && newSetting <= 100 )
        super.setSliderSetting(newSetting: newSetting)
        
        let percent: Double = Double(sliderSetting/100)
        let diff: Int = (maxSliderVal - minSliderVal)
        let percentDiff = Int(Double(diff) * percent)
        currVal = minSliderVal + percentDiff
    }
}


 
 /*
struct InventoryList<T> {
    var items: [T]
    mutating func add(item: T) {
        items.append(item)
    }
    mutating func remove() -> T {
        return items.removeLast()
    }
    func isCapacityLow() -> Bool {
        return items.count < 3
    }
}
 */

