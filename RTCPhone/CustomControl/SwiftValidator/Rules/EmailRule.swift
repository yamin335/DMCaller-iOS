//
//  EmailValidation.swift
//
//  Created by Jeff Potter on 11/11/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

/**
 `EmailRule` is a subclass of RegexRule that defines how a email is validated.
 */
public class EmailRule: RegexRule {
    
    /// Regular express string to be used in validation.
    static let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    /**
     Initializes an `EmailRule` object to validate an email field.
     
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = ""){
        self.init(regex: EmailRule.regex, message: message)
    }
}

/**
 `WebsiteRule` is a subclass of RegexRule that defines how a website is validated.
 */
public class WebsiteRule: RegexRule {
    
    /// Regular express string to be used in validation.
    static let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
    static let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
    static let regex = "^[wW]{3}+.[a-zA-Z0-9]{3,}+.[a-z]{2,}"
    
    /**
     Initializes an `WebsiteRule` object to validate an email field.
     
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = ""){
        let urlRegEx = WebsiteRule.head+"+(.)+"+WebsiteRule.tail
        self.init(regex: urlRegEx, message: message)
    }
}


/**
 `BDMobileRule` is a subclass of RegexRule that defines how a website is validated.
 */
public class MobileNumberRule: RegexRule {
    
    /// Regular express string to be used in validation.
    static let regex = "[0-9]{11,}"
    
    /**
     Initializes an `FirstNameLastNameRule` object to validate an email field.
     
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = ""){
        self.init(regex: MobileNumberRule.regex, message: message)
    }
}

/**
 `OnlyNumberRule` is a subclass of RegexRule that defines how a number is validated.
 */
public class OnlyNumberRule: RegexRule {
    
    /// Regular express string to be used in validation.
    static let regex = "[0-9]"
    
    /**
     Initializes an `FirstNameLastNameRule` object to validate an email field.
     
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = ""){
        self.init(regex: OnlyNumberRule.regex, message: message)
    }
}


/**
 `Currency` is a subclass of RegexRule that defines how a amount is validated.
 */
public class CurrencyRule: RegexRule {
    
    /// Regular express string to be used in validation.
    static let regex = "[৳,0-9 ]+(\\.[0-9][0-9]?)?" // "[৳,0-9 ]+(\\.[0-9][0-9]?)?"
    
    /**
     Initializes an `Currency` object to validate an email field.
      
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = ""){
        self.init(regex: CurrencyRule.regex, message: message)
    }
}


public class EmailRuleForNonMandatoryField: Rule {
    
    /// Regular express string to be used in validation.
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    private var message : String = ""
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
            let test = NSPredicate(format: "SELF MATCHES %@", self.regex)
            return test.evaluate(with: value)
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

public class WebsiteRuleNonMandatoryField: Rule {
    
    /// Regular express string to be used in validation.
    static let head     = "((http|https)://)?([(w|W)]{3}+\\.)?"
    static let tail     = "\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?"
    static let regex = "^[wW]{3}+.[a-zA-Z0-9]{3,}+.[a-z]{2,}"
    
    private var message : String = ""
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
            let urlRegEx = WebsiteRule.head+"+(.)+"+WebsiteRule.tail
            let test = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
            return test.evaluate(with: value)
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
