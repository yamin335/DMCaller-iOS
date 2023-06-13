//
//  Validator.swift
//
//  Created by Jeff Potter on 11/10/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation
import UIKit

/**
 Class that makes `Validator` objects. Should be added as a parameter to ViewController that will display
 validation fields.
 */
public class Validator: NSObject {
    /// Dictionary to hold all fields (and accompanying rules) that will undergo validation.
    public var validations = ValidatorDictionary<ValidationRule>()
    /// Dictionary to hold fields (and accompanying errors) that were unsuccessfully validated.
    public var errors = ValidatorDictionary<ValidationError>()
    /// Dictionary to hold fields by their object identifiers
    private var fields = ValidatorDictionary<Validatable>()
    /// Variable that holds success closure to display positive status of field.
    private var successStyleTransform:((_ validationRule:ValidationRule)->Void)?
    /// Variable that holds error closure to display negative status of field.
    private var errorStyleTransform:((_ validationError:ValidationError)->Void)?
    /// - returns: An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
    public override init(){
        super.init()
    }
    
    var validationsRules:[ValidationRule] = []
    var textFieldPreviousText: String = ""
    var tag: Int = 1
    // MARK: Private functions
    
    /**
    This method is used to validate all fields registered to Validator. If validation is unsuccessful,
    field gets added to errors dictionary.
    
    - returns: No return value.
    */
    private func validateAllFields() {
        
        errors = ValidatorDictionary<ValidationError>()
        
        for (_, rule) in validations {
            if let error = rule.validateField() {
                errors[rule.field] = error
                
                // let the user transform the field if they want
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
            } else {
                // No error
                // let the user transform the field if they want
                if let transform = self.successStyleTransform {
                    transform(rule)
                }
            }
        }
    }
    
    // MARK: Public functions
    
    /**
    This method is used to validate a single field registered to Validator. If validation is unsuccessful,
    field gets added to errors dictionary.
    
    - parameter field: Holds validator field data.
    - returns: No return value.
    */
    public func validateField(_ field: ValidatableField, callback: (_ error:ValidationError?) -> Void){
        if let fieldRule = validations[field] {
            if let error = fieldRule.validateField() {
                errors[field] = error
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
                callback(error)
            } else {
                if let transform = self.successStyleTransform {
                    transform(fieldRule)
                }
                callback(nil)
            }
        } else {
            callback(nil)
        }
    }
    
    // MARK: Using Keys
    
    /**
    This method is used to style fields that have undergone validation checks. Success callback should be used to show common success styling and error callback should be used to show common error styling.
    
    - parameter success: A closure which is called with validationRule, an object that holds validation data
    - parameter error: A closure which is called with validationError, an object that holds validation error data
    - returns: No return value
    */
    public func styleTransformers(success:((_ validationRule:ValidationRule)->Void)?, error:((_ validationError:ValidationError)->Void)?) {
        self.successStyleTransform = success
        self.errorStyleTransform = error
    }

    /**
     This method is used to add a field to validator.
     
     - parameter field: field that is to be validated.
     - parameter errorLabel: A UILabel that holds error label data
     - parameter rules: A Rule array that holds different rules that apply to said field.
     - returns: No return value
     */
    public func registerField(_ field: ValidatableField, errorLabel:UILabel? = nil, rules:[Rule]) {
        
        let validationRule = ValidationRule(field: field, rules:rules, errorLabel:errorLabel)
        validations[field] = validationRule
        fields[field] = field
        validationsRules.append(validationRule)
        if let textField = field as? UITextField {
            //textField.tag = tag++
            
            textField.addTarget(self, action: #selector(Validator.textFieldDidChange(_:)), for: .editingChanged)
             textField.delegate = self
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textFieldPreviousText = textField.text ?? ""
        
        var isNeedEmpty = false
        var actualLength = textFieldPreviousText.count
        
        for validationRule in validationsRules {
            for fieldRule in validationRule.rules {
                if let rule = fieldRule as? MaxLengthRule, let length = rule.length, let field = validationRule.field as? UITextField, field === textField {
                    if let textString = textField.text, textString.count > length {
                        actualLength = length
                        isNeedEmpty = true
                        break
                    }
                }
            }
        }
        
        if isNeedEmpty {
            textField.text = textField.text?.prefix(actualLength).stringTrimValue()
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        validateField(textField, callback: { error in
        })
    }
    
    /**
     This method is for removing a field validator.
     
     - parameter field: field used to locate and remove field from validator.
     - returns: No return value
     */
    public func unregisterField(_ field:ValidatableField) {
        validations.removeValueForKey(field)
        errors.removeValueForKey(field)
    }
    
    /**
     This method checks to see if all fields in validator are valid.
     
     - returns: No return value.
     */
    public func validate(_ delegate:ValidationDelegate) {
        
        self.validateAllFields()
        
        if errors.isEmpty {
            delegate.validationSuccessful()
        } else {
            delegate.validationFailed(errors.map { (fields[$1.field]!, $1) })
        }
        
    }
    
    /**
     This method validates all fields in validator and sets any errors to errors parameter of callback.
     
     - parameter callback: A closure which is called with errors, a dictionary of type Validatable:ValidationError.
     - returns: No return value.
     */
    public func validate(_ callback:(_ errors:[(Validatable, ValidationError)])->Void) -> Void {
        
        self.validateAllFields()
        
        callback(errors.map { (fields[$1.field]!, $1) } )
    }
}
extension Validator: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        for validationRule in validationsRules {
            for fieldRule in validationRule.rules {
                if let rule = fieldRule as? MaxLengthRule, let length = rule.length, let field = validationRule.field as? UITextField, field === textField {
                    if let textString = textField.text, textString.count > length {
                        
//                        if newLength > length {
//                            return false
//                        }
                        
                        return newLength <= length
                    }
                }
            }
        }

        return true // replace 30 for your max length value
    }
}
