//
//  Color_Extensions.swift
//
//  Created by Mamun Ar Rashid on 7/23/17.
//  Copyright © 2017 Fantasy Apps. All rights reserved.

import UIKit
import Foundation

// Utility methods to make UIColor work with hex color values
public extension UIColor {
    
     /**
    The shorthand three-digit hexadecimal representation of color.
    #RGB defines to the color #RRGGBB.
    
    - parameter hex3: Three-digit hexadecimal value.
    - parameter alpha: 0.0 - 1.0. The default is 1.0.
    */
    
    public class func colorFrom1(hexString hexStr: String, alpha: CGFloat = 1) -> UIColor? {
        // 1. Make uppercase to reduce conditions
        var cStr = hexStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased();
        
        // 2. Check if valid input
        let validRange = cStr.range(of: "\\b(0X|#)?([0-9A-F]{3,4}|[0-9A-F]{6}|[0-9A-F]{8})\\b", options: NSString.CompareOptions.regularExpression)
        if validRange == nil {
            print("Error: Inavlid format string: \(hexStr). Check documantation for correct formats", terminator: "")
            return nil
        }
        
        cStr = cStr.substring(with: validRange!)
        
        if(cStr.hasPrefix("0X")) {
            cStr = cStr.substring(from: cStr.characters.index(cStr.startIndex, offsetBy: 2))
        } else if(cStr.hasPrefix("#")) {
            cStr = cStr.substring(from: cStr.characters.index(cStr.startIndex, offsetBy: 1))
        }
        
        let strLen = cStr.characters.count
        if (strLen == 3 || strLen == 4) {
            // Make it double
            var str2 = ""
            for ch in cStr.characters {
                str2 += "\(ch)\(ch)"
            }
            cStr = str2
        } else if (strLen == 6 || strLen == 8) {
            // Do nothing
        } else {
            return nil
        }
        
        let scanner = Scanner(string: cStr)
        var hexValue: UInt32 = 0
        if scanner.scanHexInt32(&hexValue) {
            if cStr.characters.count == 8 {
                let hex8: UInt32 = hexValue
                let divisor = CGFloat(255)
                let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
                let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
                let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
                let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)            }
            else {
                let hex6: UInt32 = hexValue
                let divisor = CGFloat(255)
                let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
                let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
                let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
        } else {
            print("scan hex error")
        }
        
        return nil
    }

}

