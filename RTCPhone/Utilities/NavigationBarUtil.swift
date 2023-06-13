//
//  NavigationBarUtil.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 2/3/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//

import Foundation
import UIKit

class RCTStatusUINavigationController : UINavigationController {
    var isNavigationItemAdded: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

protocol TopBarActionDelegate {
    func returnToTheCall()
}

public class NavigationBarUtil {
    
    var isOnline: Bool = false
    
    let appInfoView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
    
    let imageFlagView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width-93, y: 2, width: 18, height: 18))
    
    let appversionLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width-70, y: 0, width: 70, height: 25))
    
    let callRunningIndicator = UILabel(frame: CGRect(x: 30, y: 0, width: 150, height: 30))
    
    var topBarActionDelegate: TopBarActionDelegate?

    
    func updateOnlineStatus (isOnline: Bool) {

        self.isOnline = isOnline
        
        //appInfoView.removeFromSuperview()
        imageFlagView.removeFromSuperview()
        appversionLabel.removeFromSuperview()
        
        appversionLabel.textColor = UIColor.white
        appversionLabel.textAlignment = .left
        
        callRunningIndicator.removeFromSuperview()
        callRunningIndicator.textColor = UIColor.white
        callRunningIndicator.textAlignment = .center
        callRunningIndicator.backgroundColor = .green
        callRunningIndicator.text = "Return to the call"
        callRunningIndicator.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.leftItemTapAction (_:)))
        callRunningIndicator.addGestureRecognizer(tapGesture)
        callRunningIndicator.isHidden = true
        appInfoView.addSubview(callRunningIndicator)
        
        //appversionLabel.isHidden = true
        
        if  self.isOnline {
            appversionLabel.text = "Online"
            imageFlagView.image = UIImage(named: "online")
        } else {
            appversionLabel.text = "Offline"
            imageFlagView.image = UIImage(named: "offline")
        }
     
        appInfoView.addSubview(appversionLabel)
        
        imageFlagView.layer.cornerRadius = 9
        imageFlagView.layer.borderWidth = 2
        imageFlagView.layer.borderColor = UIColor.white.cgColor
        imageFlagView.layer.masksToBounds = true
        
        appInfoView.addSubview(imageFlagView)
        appInfoView.layoutSubviews()
    }
    
    func addView () -> UIView {
        return appInfoView
    }
    
    init(actionDelegate: TopBarActionDelegate?) {
        self.topBarActionDelegate = actionDelegate
        
        appInfoView.contentMode = .scaleAspectFit
        appInfoView.backgroundColor =  .clear
        
        appversionLabel.textColor = UIColor.white
        appversionLabel.textAlignment = .left
        
        callRunningIndicator.textColor = UIColor.white
        callRunningIndicator.textAlignment = .center
        callRunningIndicator.backgroundColor = .green
        callRunningIndicator.text = "Return to the call"
        callRunningIndicator.layer.cornerRadius = 15
        callRunningIndicator.layer.masksToBounds = true
        callRunningIndicator.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.leftItemTapAction (_:)))
        callRunningIndicator.addGestureRecognizer(tapGesture)
        callRunningIndicator.isHidden = true
        appInfoView.addSubview(callRunningIndicator)
        
        //appversionLabel.isHidden = true
        
        if  self.isOnline {
            appversionLabel.text = "Online"
            imageFlagView.image = UIImage(named: "online")
        } else {
            appversionLabel.text = "Offline"
            imageFlagView.image = UIImage(named: "offline")
        }
        
        appInfoView.addSubview(appversionLabel)
        imageFlagView.layer.cornerRadius = 9
        imageFlagView.layer.borderWidth = 2
        imageFlagView.layer.borderColor = UIColor.white.cgColor
        imageFlagView.layer.masksToBounds = true
        
        appInfoView.addSubview(imageFlagView)
    }
    
    @objc func leftItemTapAction (_ sender: UITapGestureRecognizer) {
        print("Tap Gesture Working")
        topBarActionDelegate?.returnToTheCall()
    }
}
