//
//  PasswordLoginViewController.swift
//  SmileLock-Example
//
//  Created by rain on 4/22/16.
//  Copyright © 2016 RECRUIT LIFESTYLE CO., LTD. All rights reserved.
//

import UIKit
import LocalAuthentication

class PasswordLoginViewController: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var pinStatusLabel: UILabel!
    @IBOutlet weak var sequenceStatusLabel: UILabel!
    let kMsgShowReason = "Use Touch ID to Login CashBaba"
    var context = LAContext()
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var newPin: String?
    var isNeedCreatNewPin: Bool = false
    //var progressHUD: ProgressHUDManager?
    var isTouchCalled: Bool = false
    var isAddBeneficiary: Bool = false
    var completion: ((_ isSuccess: Bool)->Void)?
    var exitClicked: (()->Void)?
    var isResetPin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sequenceStatusLabel.text = ""
        //sequenceStatusLabel.isHidden = true
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        //passwordContainerView.deleteButtonLocalizedTitle = "smilelock_delete"
        passwordContainerView.isAddBeneficiary = isAddBeneficiary
        passwordContainerView.exitClicked = { phoneNumber in 
            if let completion = self.completion {
                completion(false)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        //customize password UI
        passwordContainerView.tintColor = UIColor.color(.textColor)
        passwordContainerView.highlightedColor = UIColor.color(.blue)
        
//        if let pin = AuthManager.getPin(), !pin.isEmpty {
//            pinStatusLabel.text = "Enter Pin"
//        } else {
            pinStatusLabel.text = "Type Number"
           // isNeedCreatNewPin = true
        //}
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { notification in
            self.updateUI()
        }
        self.updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if enterPassLabel.text != "Re-enter your new Pin" {
            updateUI()
        //}
    }
    
}

extension PasswordLoginViewController: PasswordInputCompleteProtocol {
    
    
    func didEnterInput(_ passwordContainerView: PasswordContainerView, input: String) {
        if !input.isEmpty {
           sequenceStatusLabel.text = ""
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasswordLoginViewController {
    
    func validation(_ input: String) -> Bool {
        
         return true
        
        if let pin = newPin {
            return input == pin
        } 
        
        if isNeedCreatNewPin {
            let list = input.map({Int($0.description)!})
            let consecutives = list.map { $0 - 1 }.dropFirst() == list.dropLast()
            if consecutives {
                sequenceStatusLabel.text = "Please use random number"
                return false
            }
            let reverseList = input.map({Int($0.description)!})
            let consecutivesR = reverseList.map { $0 + 1 }.dropFirst() == reverseList.dropLast()
            if consecutivesR {
                sequenceStatusLabel.text = "Please use random number"
                return false
            }
            newPin = input
            return true
        }
        
       return false
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        
        if let completion = completion, isAddBeneficiary {
            completion(true)
            dismiss(animated: true, completion: nil)
        } else {
        
        if isNeedCreatNewPin {
            passwordContainerView.clearInput()
            pinStatusLabel.text = "Re-type Pin"
            isNeedCreatNewPin = false
        } else {
           
        }
        }
        //dismiss(animated: true, completion: nil)
    }
    func loginCalled() {
//        self.progressHUD = ProgressHUDManager(view: self.view)
//        self.progressHUD?.start()
//        self.progressHUD?.isNeedShowSpinnerOnly = true
//
      /*  AuthManager.maganeProfileAfterPin(completion: { [weak self]
            result in
            guard let strongSelf = self else {
                return
            }
            switch(result){
                
            case .success(_, let client, _):
                if let loginUser = RCTAPIManager.currentLoggedinClient {
                    self?.progressHUD?.onSucceed() {
                        AuthManager.navigateAfterPin(loginUser:loginUser)
                    }
                } else {
                    self?.progressHUD?.onFailed() {
                        AuthManager.gotoLoginVC()
                    }
                }
            case .failure(let response, let error):
                self?.progressHUD?.failledStatus = "Failed"
                if let response = response {
                    self?.progressHUD?.failledMessage = response.message ?? "Failed"
                } else if let error = error {
                    self?.progressHUD?.failledMessage = error.localizedDescription
                }
                self?.progressHUD?.isNeedShowSpinnerOnly = false
                self?.progressHUD?.onFailed() {
                    AuthManager.gotoLoginVC()
                }
            }
        })*/
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword() { [weak self] in
        
        if let _ = self?.newPin {
            self?.pinStatusLabel.text = "Enter New Pin"
            self?.newPin = nil
            self?.passwordContainerView.clearInput()
            self?.isNeedCreatNewPin = true
        }
        }
    }
    func updateUI() {
        if isTouchCalled {
            return
        }
        isTouchCalled = true
        
        var policy: LAPolicy?
        // Depending the iOS version we'll need to choose the policy we are able to use
        if #available(iOS 9.0, *) {
            // iOS 9+ users with Biometric and Passcode verification
            policy = .deviceOwnerAuthentication
        } else {
            // iOS 8+ users with Biometric and Custom (Fallback button) verification
            context.localizedFallbackTitle = "Fuu!"
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
        
        var err: NSError?
        
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            //image.image = UIImage(named: "TouchID_off")
            // Print the localized message received by the system
            //message.text = err?.localizedDescription
            return
        }
        
        // Great! The user is able to use his/her Touch ID 👍
        //image.image = UIImage(named: "TouchID_on")
        //message.text = kMsgShowFinger
        
        loginProcess(policy: policy!)
    }
    
    private func loginProcess(policy: LAPolicy) {
        // Start evaluation process with a callback that is executed when the user ends the process successfully or not
//        self.progressHUD = ProgressHUDManager(view: self.view)
//        self.progressHUD?.start()
//        self.progressHUD?.isNeedShowSpinnerOnly = true
        context.evaluatePolicy(policy, localizedReason: kMsgShowReason, reply: {[weak self] (success, error) in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    //self.refresh.alpha = 1
                })
                
                guard success else {
                    guard let error = error else {
                        //self.showUnexpectedErrorMessage()
                        return
                    }
                    switch(error) {
                    case LAError.authenticationFailed: break
                                                //self.message.text = "There was a problem verifying your identity."
                                            case LAError.userCancel:
                         //self.message.text = "Authentication was canceled by user."
//                         Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
//                         By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
                        return
                                            case LAError.userFallback:
                                                fallthrough
                                                //self.message.text = "The user tapped the fallback button (Fuu!)"
                                            case LAError.systemCancel:
                                                fallthrough
                                                //self.message.text = "Authentication was canceled by system."
                                            case LAError.passcodeNotSet:
                                                 fallthrough
                                                //self.message.text = "Passcode is not set on the device."
                                            case LAError.touchIDNotAvailable:
                                                 fallthrough
                                                //self.message.text = "Touch ID is not available on the device."
                                            case LAError.touchIDNotEnrolled:
                                                 fallthrough
                                               // self.message.text = "Touch ID has no enrolled fingers."
                                            // iOS 9+ functions
                                            case LAError.touchIDLockout:
                                                fallthrough
                                                //self.message.text = "There were too many failed Touch ID attempts and Touch ID is now locked."
                                            case LAError.appCancel:
                                                fallthrough
                                               // self.message.text = "Authentication was canceled by application."
                                            case LAError.invalidContext:
                                                fallthrough
                                                //self.message.text = "LAContext passed to this call has been previously invalidated."
                    // MARK: IMPORTANT: There are more error states, take a look into the LAError struct
                        
                    default:
                        return
                    }
                    return
                }
                
                if let completion = self?.completion, let isAddbeneficiary = self?.isAddBeneficiary, isAddbeneficiary{
                    completion(true)
                    self?.dismiss(animated: true, completion: nil)
                } else {

                }
                print("Login success")
                
                // Good news! Everything went fine 👏
                //self.message.text = self.kMsgFingerOK
            }
        })
    }
}
