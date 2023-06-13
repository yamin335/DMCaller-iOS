//
//  NavigationManager.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import UIKit

public class NavigationManager {
    static func setViewController(_ vc:UIViewController, left:Bool = false, completion: (() -> Void)? = nil) {
        if let window = UIApplication.shared.delegate?.window {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.push
            transition.subtype = left ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
            
            window?.layer.removeAllAnimations()
            window?.layer.add(transition, forKey: kCATransition)
            window?.rootViewController = vc
            
            CATransaction.commit()
        }
    }
}

extension NavigationManager {
    static func setLoginViewController(_ vc:UIViewController, completion: (() -> Void)? = nil) {
        if let window = UIApplication.shared.delegate?.window {
            //            CATransaction.begin()
            //            CATransaction.setCompletionBlock(completion)
            //
            //            let transition = CATransition()
            //            transition.duration = 0.3
            //            transition.type = kCATransitionPush
            //            transition.subtype = left ? kCATransitionFromLeft : kCATransitionFromRight
            //            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
            //
            //            window?.layer.removeAllAnimations()
            //            window?.layer.add(transition, forKey: kCATransition)
            window?.rootViewController = vc
            
            // CATransaction.commit()
        }
    }
}
