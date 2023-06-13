//
//  MaxLengthTextField.swift
//  Swift 3 Text Field Magic 2
//
//  Created by Joey deVilla on 2016-09-03.
//  MIT license. See the end of this file for the gory details.
//
//  Accompanies the article in Global Nerdy (http://globalnerdy.com):
//  "Swift 3 text field magic, part 1: Creating text fields with maximum lengths"
//  http://www.globalnerdy.com/2016/09/05/swift-3-text-field-magic-part-1-creating-text-fields-with-maximum-lengths/
//


import UIKit

class MaxLengthTextField: UITextField, UITextFieldDelegate {
  
  private var characterLimit: Int? = 4
  
  public var nextFucusTextField: UITextField?
  public var prevFucusTextField: UITextField?
  
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        //self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        delegate = self
       // self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
  
  @IBInspectable var maxLength: Int {
    get {
      guard let length = characterLimit else {
        return Int.max
      }
      return length
    }
    set {
      characterLimit = newValue
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.text?.characters.count == 0, let prevFucusTextField = prevFucusTextField {
        //self.resignFirstResponder()
        prevFucusTextField.becomeFirstResponder()
    }
    
    return true
  }

 
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
   
//    if textField.text?.characters.count == 0, let prevFucusTextField = prevFucusTextField {
//        //self.resignFirstResponder()
//        prevFucusTextField.becomeFirstResponder()
//        return true
//    }
    
//    if textField.text?.characters.count == 1, let nextFucusTextField = nextFucusTextField {
//        //self.resignFirstResponder()
//        nextFucusTextField.becomeFirstResponder()
//        return true
//    }
    
    guard string.characters.count > 0 else {
      return true
    }
    
    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    // 1. Here's the first change...
    return allowedIntoTextField(text: prospectiveText)
  }
  
  // 2. ...and here's the second!
  func allowedIntoTextField(text: String) -> Bool {
    return text.characters.count <= maxLength
  }
  
}

