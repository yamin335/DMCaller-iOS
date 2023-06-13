//
//  ProgressHUDManager.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 8/29/17.
//  Copyright © 2017 Recursion Technologies Ltd. All rights reserved.
//

import UIKit
import MBProgressHUD

public class ProgressHUDManager {
    // MARK:- Properties
    var progressHUB: MBProgressHUD?
    var forView: UIView
    
    var isNeedShowButtonOnFailure: Bool = false
    var isNeedShowButtonOnSuccess: Bool = false
    var isNeedShowImage: Bool = true
    var isNeedShowSpinnerOnly: Bool = false
    var doneCompletion: (()->Void)? = nil
    
    var isNeedWaitForUserAction: Bool = false {
        didSet {
         isNeedShowButtonOnFailure = isNeedWaitForUserAction
         isNeedShowButtonOnSuccess = isNeedWaitForUserAction
        }
    }
    
    var successImage: UIImage = UIImage(named: "Checkmark")!
    var failureImage: UIImage = UIImage(named: "cross")!
    
    var failledStatus = "Failed"
    var failledMessage = "Operation Failed"
    var successStatus = "Success"
    var successMessage = "Operation successfully done"
    
    // MARK:- Methods
    func start(){
         DispatchQueue.main.async {
            self.progressHUB = MBProgressHUD.showAdded(to: self.forView, animated: true)
            self.progressHUB?.label.font = UIFont.boldSystemFont(ofSize: 20)
            self.progressHUB?.detailsLabel.font = UIFont.systemFont(ofSize: 16)
            self.progressHUB?.label.text = "Processing..."
            self.progressHUB?.minSize = CGSize(width: 150, height: 100)
            self.progressHUB?.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        }
    }
    
    init(view: UIView) {
        forView = view
    }
    
    func end(_ completion: (()->Void)? = nil){
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.progressHUB?.hide(animated: true)
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    func onLoginSucceed(_ completion: (()->Void)? = nil) {
        
        self.doneCompletion = completion
        
        DispatchQueue.global().async { [weak self] in
            
            //sleep(1)
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    if let completion = completion {
                        return completion()
                    }
                    return
                }
                
                if strongSelf.isNeedShowImage && !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.customView = UIImageView(image: strongSelf.successImage)
                    strongSelf.progressHUB?.mode = MBProgressHUDMode.customView
                }
                
                if !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.label.text = strongSelf.successStatus
                    strongSelf.progressHUB?.detailsLabel.text = strongSelf.successMessage
                }
                
                if strongSelf.isNeedShowButtonOnSuccess && !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.button.setTitle("Ok", for: .normal)
                    strongSelf.progressHUB?.button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
                    strongSelf.progressHUB?.button.backgroundColor = UIColor.blue
                    strongSelf.progressHUB?.button.addTarget(strongSelf, action: #selector(ProgressHUDManager.done(_:)), for: .touchUpInside)
                    //strongSelf.doneCompletion = completion
                }
                
            }
            
            //sleep(1)
            
            if let isNeedShowButton = self?.isNeedShowButtonOnSuccess, let isNeedShowSpinnerOnly = self?.isNeedShowSpinnerOnly,!isNeedShowButton || isNeedShowSpinnerOnly {
                sleep(1)
                //
                DispatchQueue.main.async { [weak self] in
                    self?.progressHUB?.hide(animated: true)
                    if let completion = self?.doneCompletion {
                        return completion()
                    }
                }
            }

            
        }
    }
    
    func onSucceed(_ completion: (()->Void)? = nil) {
        
        self.doneCompletion = completion
        
        DispatchQueue.global().async { [weak self] in

            sleep(1)
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    if let completion = completion {
                        return completion()
                    }
                    
                    return
                }
                
                if strongSelf.isNeedShowImage && !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.customView = UIImageView(image: strongSelf.successImage)
                    strongSelf.progressHUB?.mode = MBProgressHUDMode.customView
                }
                
                if !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.label.text = strongSelf.successStatus
                    strongSelf.progressHUB?.detailsLabel.text = strongSelf.successMessage
                }
                
                if strongSelf.isNeedShowButtonOnSuccess && !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.button.setTitle("Ok", for: .normal)
                    strongSelf.progressHUB?.button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
                    strongSelf.progressHUB?.button.addTarget(strongSelf, action: #selector(ProgressHUDManager.done(_:)), for: .touchUpInside)
                    strongSelf.doneCompletion = completion
                }
            }
            
            if let isNeedShowButton = self?.isNeedShowButtonOnSuccess, let isNeedShowSpinnerOnly = self?.isNeedShowSpinnerOnly,!isNeedShowButton || isNeedShowSpinnerOnly {
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.progressHUB?.hide(animated: true)
                    if let completion = self?.doneCompletion {
                        completion()
                    }
                }
            }
        }
    }

    func onFailed(_ completion: (()->Void)? = nil) {
        
        DispatchQueue.global().async { [weak self] in
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    if let completion = completion {
                       return completion()
                    }
                    
                    return
                }
                
                if strongSelf.isNeedShowImage && !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.customView = UIImageView(image: strongSelf.failureImage)
                    strongSelf.progressHUB?.mode = MBProgressHUDMode.customView
                }
                
                if !strongSelf.isNeedShowSpinnerOnly {
                    strongSelf.progressHUB?.label.text = strongSelf.failledStatus
                    strongSelf.progressHUB?.detailsLabel.text = strongSelf.failledMessage
                }
                
                if strongSelf.isNeedShowButtonOnFailure {
                    strongSelf.progressHUB?.button.setTitle("Ok", for: .normal)
                    strongSelf.progressHUB?.button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
                    strongSelf.progressHUB?.button.addTarget(strongSelf, action: #selector(ProgressHUDManager.done(_:)), for: .touchUpInside)
                    strongSelf.doneCompletion = completion

                }
            }
            
            if let isNeedShowButton = self?.isNeedShowButtonOnFailure, !isNeedShowButton {
                sleep(1)
                DispatchQueue.main.async { [weak self] in
                    self?.progressHUB?.hide(animated: true)
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    @objc func done(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.progressHUB?.hide(animated: true)
            if let completion = self.doneCompletion {
                completion()
            }
        }
    }
    
}


extension  UIViewController {
    func showAlert(withTitle title: String = ValidationErrors.error.description, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
        })
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}

extension UIViewController {
    
    func showLoading(hud: ProgressHUDManager) {
        hud.start()
        hud.isNeedShowSpinnerOnly = true
    }
    
    func endLoading(hud: ProgressHUDManager) {
        hud.end()
    }
    
    func succeessWithEndLoading(hud: ProgressHUDManager, completion: (() -> Void)?) {
        hud.end({
            if let completion =  completion {
                completion()
            }
        })
    }
    
    func showSuccessMessage(hud: ProgressHUDManager,isNeedTowait:Bool, data: String, completion: (() -> Void)? ) {
        hud.isNeedWaitForUserAction = isNeedTowait
        hud.isNeedShowSpinnerOnly = false
        hud.isNeedShowImage = isNeedTowait
        hud.successStatus = "Success"
        hud.successMessage = data
        hud.onSucceed({
            if let completion =  completion {
                completion()
            }
        })
    }
    
    func showFailedMessage(hud: ProgressHUDManager, isNeedTowait:Bool, data: String, completion: ((Bool) -> Void)?) {
        hud.isNeedShowSpinnerOnly = false
        hud.isNeedWaitForUserAction = isNeedTowait
        hud.isNeedShowImage = isNeedTowait
        hud.failledStatus = "Failed"
        hud.failledMessage = data
        hud.onFailed({
            if let completion =  completion {
                completion(true)
            }
        })
    }
}
