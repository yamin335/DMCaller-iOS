//
//  ValidateCardNumberRule.swift
//  CashBaba
//
//  Created by Asif Newaz on 3/1/21.
//  Copyright © 2021 Recursion Technologies Ltd. All rights reserved.
//

import Foundation

open class ValidateCardNumberRule: Rule {
    /// String that holds error message.
    private var message : String = "Card number is not valid"
    /**
     Initializes `PasswordStrengthChecker` object with error message. Used to validate a field that requires text.
     
     - parameter message: String of error message.
     - returns: An initialized `PasswordStrengthChecker` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(message : String = ""){
        self.message = message
    }
    
    /**
     Validates a field.
     
     - parameter value: String to checked for validation.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    open func validate(_ value: String) -> Bool {
        if value.isNotEmpty {
            var sum = 0
            let reversedCharacters = value.reversed().map { String($0) }
            for (idx, element) in reversedCharacters.enumerated() {
                guard let digit = Int(element) else { return false }
                switch ((idx % 2 == 1), digit) {
                case (true, 9): sum += 9
                case (true, 0...8): sum += (digit * 2) % 9
                default: sum += digit
                }
            }
            let isValid = sum % 10 == 0
            print("Card valid? : \(isValid)")
            return isValid
        } else {
            return true
        }
    }
    
    /**
     Used to display error message when validation fails.
     
     - returns: String of error message.
     */
    open func errorMessage() -> String {
        return self.message
    }
    
}

open class ValidateUPICardNumberRule: Rule {
    /// String that holds error message.
    private var message : String = "Card number is not valid"
    /**
     Initializes `PasswordStrengthChecker` object with error message. Used to validate a field that requires text.
     
     - parameter message: String of error message.
     - returns: An initialized `PasswordStrengthChecker` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(message : String = ""){
        self.message = message
    }
    
    /**
     Validates a field.
     
     - parameter value: String to checked for validation.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    open func validate(_ value: String) -> Bool {
        if value.isNotEmpty {
            var sum = 0
            let reversedCharacters = value.reversed().map { String($0) }
            for (idx, element) in reversedCharacters.enumerated() {
                guard let digit = Int(element) else { return false }
                switch ((idx % 2 == 1), digit) {
                case (true, 9): sum += 9
                case (true, 0...8): sum += (digit * 2) % 9
                default: sum += digit
                }
            }
            let isValid = sum % 10 == 0
            print("Card valid? : \(isValid)")
            if isValid {
                if value.count >= 16 {
                    let prefix = value.prefix(8)
                    if prefix == "62293446" || prefix == "62293447" || prefix == "62293448"  {
                        return isValid
                    } else {
                        return false
                    }
                }
                return false
            }
            return isValid
        } else {
            return true
        }
    }
    
    /**
     Used to display error message when validation fails.
     
     - returns: String of error message.
     */
    open func errorMessage() -> String {
        return self.message
    }
    
}

