//
//  StringExtension.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 9/20/17.
//  Copyright © 2017 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

extension String {
    static func isEmptyOrNull(_ string: String?) -> Bool {
        if let string = string {
            return string.trim().isEmpty ? true : false
        } else {
            return true
        }
    }
    static func formattedAmount(_ amount: NSNumber?) -> String {
        if let amount = amount {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.decimalSeparator = ","
            formatter.currencySymbol = "BDT "
            let formattedString = formatter.string(for: amount)
            return formattedString!
        } else {
            return "৳ 0.00"
        }
    }
    
    func toNSNumber() -> NSNumber?
    {
        if self.trim().isEmpty {
           return nil
        }
        if let double  = Double(self) {
          return NSNumber(value: double)
        }
        return nil
    }
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
}

extension String {
    func isPhone()->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
}

extension Substring {
    func stringTrimValue() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {
    mutating func prefix(_ maxLength: Int) -> String {
        return String(self.prefix(maxLength))
    }

    var length: Int {
        return count
    }

    
    func satisfiesRegexp(_ regexp: String) -> Bool {
        return range(of: regexp, options: .regularExpression) != nil
    }
    
    func isNumberOnly() -> Bool {
        print("validate only number: \(self)")
        let emailRegEx = "[0-9]"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: self)
        return result
    }
    
    func isValidName() -> Bool {
        let regEx = "^[A-Za-z]{1}+[A-Za-z .\\-'()]+[A-Za-z. )]{1}"
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = test.evaluate(with: self)
        return result
    }
}

