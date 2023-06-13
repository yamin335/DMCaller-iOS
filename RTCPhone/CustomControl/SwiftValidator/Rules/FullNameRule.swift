//
//  FullNameValidation.swift
//
//  Created by Jeff Potter on 11/19/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

/**
 `FullNameRule` is a subclass of Rule that defines how a full name is validated.
 */
public class FullNameRule : Rule {
    /// Error message to be displayed if validation fails.
    private var message : String
    
    /**
     Initializes a `FullNameRule` object that is used to verify that text in field is a full name.
     
     - parameter message: String of error message.
     - returns: An initialized `FullNameRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(message : String = "Invalid name"){
        self.message = message
    }
    
    /**
     Used to validate a field.
     
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        let nameArray: [String] = value.split { $0 == " " }.map { String($0) }
        return nameArray.count >= 2
    }
    
    /**
     Used to display error message of a field that has failed validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}


/**
 `FirstNameLastNameRule` is a subclass of RegexRule that defines how a website is validated.
 */
public class NameRule: RegexRule {
    
    /// Regular express string to be used in validation.
//    static let regex = "[A-Za-z .\\-'()]{1,}"
    static let regex = "^[A-Za-z]{1}+[A-Za-z .\\-'()]+[A-Za-z. )]{1}"
    
    /**
     Initializes an `FirstNameLastNameRule` object to validate an email field.
     
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(message : String = "Invalid name"){
        self.init(regex: NameRule.regex, message: message)
    }
}
