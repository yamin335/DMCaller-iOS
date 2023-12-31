//
//  LengthRule.swift
//  Validator
//
//  Created by Jeff Potter on 3/6/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

/**
 `MinLengthRule` is a subclass of Rule that defines how minimum character length is validated.
 */
public class MinLengthRule: Rule {
    /// Default minimum character length.
    private var DEFAULT_LENGTH: Int = 3
    /// Default error message to be displayed if validation fails.
    private var message : String = ""
    
    /// - returns: An initialized `MinLengthRule` object, or nil if an object could not be created for some reason that would not result in an exception.
    public init(){}
    
    /**
     Initializes a `MaxLengthRule` object that is to validate the length of the text of a field.
     
     - parameter length: Minimum character length.
     - parameter message: String of error message.
     - returns: An initialized `MinLengthRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(length: Int, message : String = "" ){
        self.DEFAULT_LENGTH = length
        let stringLength = String(self.DEFAULT_LENGTH)
        self.message = String(format: message, stringLength)
    }
    
    /**
     Validates a field.
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        return value.count >= DEFAULT_LENGTH
    }
    
    /**
     Displays error message when field has failed validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}


public class MinLengthRuleWithNullable: Rule {
    /// Default minimum character length.
    private var DEFAULT_LENGTH: Int = 3
    /// Default error message to be displayed if validation fails.
    private var message : String = ""
    
    /// - returns: An initialized `MinLengthRule` object, or nil if an object could not be created for some reason that would not result in an exception.
    public init(){}
    
    /**
     Initializes a `MaxLengthRule` object that is to validate the length of the text of a field.
     
     - parameter length: Minimum character length.
     - parameter message: String of error message.
     - returns: An initialized `MinLengthRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(length: Int, message : String = "" ){
        self.DEFAULT_LENGTH = length
        let stringLength = String(self.DEFAULT_LENGTH)
        self.message = String(format: message, stringLength)
    }
    
    /**
     Validates a field.
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        if value.isNotEmpty {
            return value.count >= DEFAULT_LENGTH
        } else {
            return true
        }
    }
    
    /**
     Displays error message when field has failed validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}
