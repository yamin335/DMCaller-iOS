//
//  MaxLengthRule.swift
//  Validator
//
//  Created by Guilherme Berger on 4/6/15.
//

import Foundation

/**
 `MaxLengthRule` is a subclass of `Rule` that defines how maximum character length is validated.
 */
public class MaxLengthRule: Rule {
    /// Default maximum character length.
    private var DEFAULT_LENGTH: Int = 16
    var length: Int?
    /// Error message to be displayed if validation fails.
    private var message : String = ""
    /// - returns: An initialized `MaxLengthRule` object, or nil if an object could not be created for some reason that would not result in an exception.
    public init(){}
    
    /**
     Initializes a `MaxLengthRule` object that is to validate the length of the text of a field.
     
     - parameter length: Maximum character length.
     - parameter message: String of error message.
     - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(length: Int, message : String = ""){
        self.length = length
        self.DEFAULT_LENGTH = length
        let stringLength = String(self.DEFAULT_LENGTH)
        self.message = String(format: message, stringLength)
    }
    
    /**
     Used to validate a field.
     
     - parameter value: String to checked for validation.
     - returns: A boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(_ value: String) -> Bool {
        return value.count <= DEFAULT_LENGTH
    }
    
    /**
     Displays an error message if a field fails validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}
