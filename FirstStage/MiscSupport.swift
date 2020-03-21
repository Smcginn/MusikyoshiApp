//
//  MiscSupport.swift
//  FirstStage
//
//  Created by Scott Freshour on 8/30/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//

import Foundation

// to get be able to have vars for debug sessions, and get rid of "unused" warning
let shoudIPrintIt = false
func dontPrint(toPrint: String)
{
    if shoudIPrintIt {
        print ("\toPrint()")
    }
}

// to  be able to have vars for debug sessions, and get rid of "unused" warning
// can use this to supress warrnings as follows:
//      let justToLookAt = someCalcOrOther()
//      if alwaysFalseToSuppressWarn() { print(\(justToLookAt)") }
func alwaysFalseToSuppressWarn() -> Bool {
    return false
}

func useThisToSuppressWarnings(str: String) {
    if alwaysFalseToSuppressWarn() {
        print("\(str)")
    }
}

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

extension UIView {
    func roundedView(radiiSz: CGSize = CGSize(width:18.0, height:12.0)) {
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: .allCorners,
                                     cornerRadii: radiiSz)
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}

//////////////////////////////////////////////////////////////////////////////
// MARK: for displaying alerts from code with unknown UIView or VC

extension UIAlertController {
    
    func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController {
            visibleViewController.present(self, animated: animated, completion: completion)
        }
    }
    
}

extension UIWindow {
    
    var visibleViewController: UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        return visibleViewController(for: rootViewController)
    }
    
    private func visibleViewController(for controller: UIViewController) -> UIViewController {
        var nextOnStackViewController: UIViewController? = nil
        if let presented = controller.presentedViewController {
            nextOnStackViewController = presented
        } else if let navigationController = controller as? UINavigationController,
            let visible = navigationController.visibleViewController {
            nextOnStackViewController = visible
        } else if let tabBarController = controller as? UITabBarController,
            let visible = (tabBarController.selectedViewController ??
                tabBarController.presentedViewController) {
            nextOnStackViewController = visible
        }
        
        if let nextOnStackViewController = nextOnStackViewController {
            return visibleViewController(for: nextOnStackViewController)
        } else {
            return controller
        }
    }
    
}

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}



// MARK: Creating attributed text

func createAttributedText(str: String, fontSize: CGFloat) -> NSMutableAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.center
    let retAttrStr =
        NSMutableAttributedString(
            string: str,
            attributes: [
                NSAttributedStringKey.font:UIFont( name: "Futura-Bold",
                                                   size: fontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.foregroundColor : UIColor.white] )
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

let kPrefixForNote  =   "    "
//                       12345678911234567892123456789312345678941234567895123456789012345
let kPrefixForLinking = "                              "
let kPrefixForSound   = "                                                                 "

func printNoteRelatedMsg(msg: String) {
    var outmsg = kPrefixForNote
    outmsg += msg
    print(outmsg)
}

func printSoundRelatedMsg(msg: String) {
    var outmsg: String = kPrefixForSound
    outmsg += msg
    print(outmsg)
}

func printLinkingRelatedMsg(msg: String) {
    var outmsg: String = kPrefixForLinking
    outmsg += msg
    print(outmsg)
}

func printAmplitude(currAmp: Double, at: Double, atComp: Double) {
    guard kDoPrintAmplitude else { return }
    let ampValStr   = String(format: "%.3f", currAmp)
    let timeStr     = String(format: "%.3f", at)
    let compTimeStr = String(format: "%.3f", atComp)

    
    let times10 = Int(currAmp * gAmplitudePrintoutMultiplier)
    let ampStr = String(repeating:"-", count:times10)
    let outStr = "At " + timeStr + ", (comp: \(compTimeStr)), Amp= " + ampValStr + " " + ampStr
    print( outStr)
}

// MARK: - for debugging and robustness

func itsBad() {
    print ("It's Bad")
}

// An "ASSERT" to be able to set a breakpoint for
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
    
    static let orangeColor = UIColor(hexString: "#ffb200ff")
    static let pinkColor = UIColor(hexString: "#ff3da8ff")
    static let fadedPinkColor = UIColor(hexString: "#ff79c3ff")
    static let disabledPinkColor = UIColor(hexString: "#653F5630")
    static let purpleColor = UIColor(hexString: "#8f46ffff")
    static let darkColor = UIColor(hexString: "#22274fff")
    static let greyTextColor = UIColor(hexString: "#d9d9d9ff")
    static let greyColor = UIColor(hexString: "#efefefff")
    
}


extension UIDevice {
    public var is_iPhoneX: Bool {
        
        if UIScreen.main.nativeBounds.height == 2436  ||  // X, XS
           UIScreen.main.nativeBounds.height == 1792  ||  // XR
           UIScreen.main.nativeBounds.height == 2688      // XS Max
        {
            return true
        } else {
            return false
        }
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

//func isiPhoneSE(usingWindowSize: Bool) -> Bool {
//    return usingWindowSize ? ScreenSize.SCREEN_WIDTH <= 480 && ScreenSize.SCREEN_HEIGHT <= 320 : isiPhoneSE()
//}

/*x
enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}
*/

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5orSE      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

class MyUIAlertController : UIAlertController {
    override var shouldAutorotate: Bool {
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

func getCurrBPM() -> TimeInterval {
    let currBPM = UserDefaults.standard.double(forKey: Constants.Settings.BPM)
    guard currBPM > 0 else {
        itsBad()
        return currBPM
    }
    
    return currBPM
}

public class AtomicInteger {
    
    private let lock = DispatchSemaphore(value: 1)
    private var value = 0
    
    // You need to lock on the value when reading it too since
    // there are no volatile variables in Swift as of today.
    public func get() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        return value
    }
    
    public func set(_ newValue: Int) {
        
        lock.wait()
        defer { lock.signal() }
        value = newValue
    }
    
    public func incrementAndGet() -> Int {
        
        lock.wait()
        defer { lock.signal() }
        value += 1
        return value
    }
}

// Get the app's sandbox dir
func getAppSupportDir() -> URL? {
    var retUrl: URL? = nil
    do {
        let fm = FileManager.default
        retUrl = try fm.url(for: .applicationSupportDirectory,
                            in: .userDomainMask,
                            appropriateFor: nil,
                            create: true)
    } catch {
        // TODO deal with error
    }
    return retUrl
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}

extension Date {
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

}

////////////////////////////////////////////////////////////////////
//
// For fixing the "EB4" to "Eb4" bug for LongTone exers and titles
//

func noteNameContains(noteName: String,
                      subString: String) -> Bool {
    let range1 = noteName.range(of: subString)
    if range1 != nil {
        return true
    } else {
        return false
    }
}

//func indexOfNoteNameSubstring(subString: String) -> Int {
//    let range1 = noteName.range(of: subString)
//    if range1 != nil {
//        let index: Int = noteName.distance(from: noteName.startIndex,
//                                           to: range1!.lowerBound)
//        return index
//    } else {
//        return -1
//    }
//}

func correctForLongToneNameFlatBug(noteName: inout String) {
    // Astonishingly, as of release 2.0.4, All LT exercises with a flat in
    // the name were not working. The noteID lookup is case sensitive; e.g.,
    // "Eb4" would work but "EB4" would not.   All exer names in the score file
    // are upper case, so they are (and remian) in the form "EB4".
    // So: detect if this is a flat note, and if so, change the "B" to a "b".
    
    if noteNameContains(noteName: noteName, subString: "DB") {
        noteName = noteName.replacingOccurrences(of: "DB", with: "Db")
    } else if noteNameContains(noteName: noteName, subString: "EB") {
        noteName = noteName.replacingOccurrences(of: "EB", with: "Eb")
    } else if noteNameContains(noteName: noteName, subString: "GB") {
        noteName = noteName.replacingOccurrences(of: "GB", with: "Gb")
    } else if noteNameContains(noteName: noteName, subString: "AB") {
        noteName = noteName.replacingOccurrences(of: "AB", with: "Ab")
    } else if noteNameContains(noteName: noteName, subString: "BB") {
        noteName = noteName.replacingOccurrences(of: "BB", with: "Bb")
    }
}

