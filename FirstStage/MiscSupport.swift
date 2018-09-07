//
//  MiscSupport.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/30/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation


func createAttributedText(str: String, fontSize: CGFloat) -> NSMutableAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center
    let retAttrStr =
        NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedStringKey.font:UIFont( name: "Marker Felt",
                                                   size: fontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle] )
    if retAttrStr.length == 0 {
        print ("Unable to create NSMutableAttributedString in createAttributedText()")
    }
    
    return retAttrStr
}

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
