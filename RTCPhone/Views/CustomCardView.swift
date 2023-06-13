//
//  CustomCardView.swift
//  RTCPhone
//
//  Created by Md. Yamin on 11/23/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

import UIKit
class CustomCardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var borderColor: UIColor = UIColor.blue
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var shadowOffsetWidth: Int = 1
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.gray
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var shadowRadius: CGFloat = 5
    @IBInspectable var masksToBounds: Bool = false
    
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = masksToBounds
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowPath = shadowPath.cgPath
    }
}
