//
//  BasicPlaceholderView.swift
//  CashBaba
//
//  Created by Mohammad Arif Hossain on 6/23/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//
import UIKit

class BasicPlaceholderView: UIView {
    
    let centerView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        backgroundColor = UIColor.white
        
        centerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(centerView)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-(>=20)-[centerView]-(>=20)-|", options: .alignAllCenterX, metrics: nil, views: ["centerView": centerView])
        let hConstraint = NSLayoutConstraint(item: centerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let centerConstraint = NSLayoutConstraint(item: centerView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        centerConstraint.priority = UILayoutPriority(rawValue: 750)
        
        addConstraints(vConstraints)
        addConstraint(hConstraint)
        addConstraint(centerConstraint)
    }
    
}
