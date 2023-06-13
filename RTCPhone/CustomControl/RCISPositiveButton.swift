//
//  RCISPositiveButton.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 12/21/17.
//  Copyright © 2017 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RCISPositiveButton: UIButton {
    
    // MARK:- Properties
    @IBInspectable var cornerRadious: CGFloat = 0 {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.white {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var customBackgroundColor: UIColor = UIColor.clear {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 16 {
        didSet{
            updateUI()
        }
    }
    
    // MARK:- Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = cornerRadious
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
        self.tintColor = textColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = customBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = customBackgroundColor
    }
    
    func updateUI() {
        self.setNeedsDisplay()
    }
}

@IBDesignable class RCISNegativeButton: UIButton {
    
    // MARK:- Properties
    @IBInspectable var cornerRadious: CGFloat = 5 {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.white {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var customBackgroundColor: UIColor = UIColor.colorFrom(hexString: "E1E1E1")! {
        didSet{
            updateUI()
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 20 {
        didSet{
            updateUI()
        }
    }
    
    // MARK:- Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = cornerRadious
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
        self.tintColor = textColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.backgroundColor = customBackgroundColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = customBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = customBackgroundColor
    }
    
    func updateUI() {
        self.setNeedsDisplay()
    }
}



