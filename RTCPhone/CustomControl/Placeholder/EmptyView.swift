//
//  EmptyView.swift
//  CashBaba
//
//  Created by Mohammad Arif Hossain on 6/23/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//
import UIKit

 class EmptyView: BasicPlaceholderView {
    
    let label = UILabel()
    var fromVC : String = ""
    

    override func setupView() {
        super.setupView()
        
        backgroundColor = UIColor.clear
        
        label.text = "No data found"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(label)
        
        let views = ["label": label]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[label]-|", options: .alignAllCenterY, metrics: nil, views: views)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", options: .alignAllCenterX, metrics: nil, views: views)
        
        centerView.addConstraints(hConstraints)
        centerView.addConstraints(vConstraints)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
    
  
    
}

