//
//  RCTButton.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 9/9/17.
//  Copyright © 2017 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RCTButton: UIButton {
    
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

@IBDesignable class RCISRoundedView: UIView {
    
    // MARK:- Properties
    @IBInspectable var cornerRadious: CGFloat = 8 {
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
    
    
    // MARK:- Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = cornerRadious
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = customBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.backgroundColor = customBackgroundColor
    }
    
    func updateUI() {
        self.setNeedsDisplay()
    }
}


