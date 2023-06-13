//
//  EmailOrMobileValidateRule.swift
//  CashBaba
//
//  Created by Asif Newaz on 24/12/20.
//  Copyright © 2020 Recursion Technologies Ltd. All rights reserved.
//

import Foundation

/**
 `EmailMobileValidateRule` is a subclass of Rule that defines how a required field is validated.
 */
open class EmailOrMobileValidateRule: Rule {
    /// String that holds error message.
    private var message : String = "Insert mobile"
    private var emailMessage : String =  ""
    
    private var isMobile : Bool = true
    private var regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    /**
     Initializes `EmailMobileValidateRule` object with error message. Used to validate a field that requires text.
     
     - parameter message: String of error message.
     - returns: An initialized `EmailMobileValidateRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(message : String = "", emailMessage : String = ""){
        self.message = message
        self.emailMessage = emailMessage
    }
    
    /**
     Validates a field.
     
     - parameter value: String to checked for validation.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    open func validate(_ value: String) -> Bool {
        if value.isNotEmpty {
            if value.isNumeric {
                self.isMobile = true
                if value.length >= 2 {
                    let firstTwo = String(value.prefix(2))
                    if firstTwo == "01" {
                        if value.length == 11 {
                            let firstThree = String(value.prefix(3))
                            if AppManager.isValidBDPhoneNumber(trimmedNumber: firstThree) {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            //Not a phone number
                            return false
                        }
                    } else {
                        //Not a phone number
                        return false
                    }
                } else {
                    //less than 2 digit
                    return true
                }
            } else {
                self.isMobile = false
                //Non number
                let test = NSPredicate(format: "SELF MATCHES %@", self.regex)
                return test.evaluate(with: value)
            }
        } else {
            //For Empty
            return true
        }
    }
    
    /**
     Used to display error message when validation fails.
     
     - returns: String of error message.
     */
    open func errorMessage() -> String {
        if isMobile {
            return message
        } else {
            return emailMessage
        }
    }
    
}


open class MobileValidateRule: Rule {
    /// String that holds error message.
    private var message : String = "Insert mobile"
    /**
     Initializes `EmailMobileValidateRule` object with error message. Used to validate a field that requires text.
     
     - parameter message: String of error message.
     - returns: An initialized `EmailMobileValidateRule` object, or nil if an object could not be created for some reason that would not result in an exception.
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
            if value.isNumeric {
                if value.length >= 1 {
                    let firstTwo = String(value.prefix(1))
                    if firstTwo == "0" {
                        if value.length == 11 {
                            let firstThree = String(value.prefix(3))
                            if AppManager.isValidBDPhoneNumber(trimmedNumber: firstThree) {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            //Not a phone number
                            return false
                        }
                    } else {
                        //Not a phone number
                        return false
                    }
                } else {
                    //less than 2 digit
                    return true
                }
            } else {
                return true
            }
        } else {
            //For Empty
            return true
        }
    }
    
    /**
     Used to display error message when validation fails.
     
     - returns: String of error message.
     */
    open func errorMessage() -> String {
        return message
    }
    
}
