//
//  MinOneCharacterCheckRule.swift
//  CashBaba
//
//  Created by Asif Newaz on 22/12/20.
//  Copyright © 2020 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
public class MinOneCharacterCheckRule: Rule {
    
    /// NSCharacter that hold set of valid characters to hold
    private let characterSet: CharacterSet = CharacterSet.letters
    /// String that holds error message
    private var message: String
    
    /**
     Initializes a `MinOneCharacterCheckRule` object to verify that field has valid set of characters.
     
     - parameter characterSet: NSCharacterSet that holds group of valid characters.
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(message: String = "") {
        self.message = message
    }
    
    /**
     Used to validate field.
     
     - parameter value: String to checked for validation.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        var isValid = false
        for uni in value.unicodeScalars {
            if let uniVal = UnicodeScalar(uni.value), characterSet.contains(uniVal) {
                isValid = true
                break
            }
        }
        return isValid
    }
    
    /**
     Displays error message when field fails validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}
