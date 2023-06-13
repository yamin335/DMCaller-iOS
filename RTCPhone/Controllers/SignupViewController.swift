//
//  SignupViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 8/12/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import INTULocationManager

class SignupViewController: UIViewController{

    @IBOutlet weak var nameTextField: UITextFieldX!
    @IBOutlet weak var companyIDTextField: UITextFieldX!
    @IBOutlet weak var mobileTextField: UITextFieldX!
    @IBOutlet weak var passwordTextField: UITextFieldX!
    @IBOutlet weak var retypePassTextField: UITextFieldX!
    @IBOutlet weak var emailTextField: UITextFieldX!
    @IBOutlet weak var registerButton: UIButtonX!
    @IBOutlet weak var showHidePass: UIButton!
    @IBOutlet weak var showHideRePass: UIButton!
    
    var progressHUD: ProgressHUDManager?
    let validator = Validator()
    
    var isTextFieldNotEmpty: Bool = false {
        didSet{
            if isTextFieldNotEmpty == true {
                if let name = nameTextField.text,  let compayID = companyIDTextField.text, let mobile = mobileTextField.text, let password = passwordTextField.text, let reTypePassword = retypePassTextField.text, let email = emailTextField.text, name.isNotEmpty, compayID.isNotEmpty, mobile.isNotEmpty, password.isNotEmpty, reTypePassword.isNotEmpty, email.isNotEmpty {
                    registerButton.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
                    registerButton.isEnabled = true
                } else {
                    registerButton.backgroundColor = UIColor.lightGray
                    registerButton.isEnabled = false
                }
            } else {
                registerButton.backgroundColor = UIColor.lightGray
                registerButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isTextFieldNotEmpty = false
        
        //MobileNumberRule(),
        validator.registerField(mobileTextField, errorLabel: nil, rules: [MaxLengthRule(length: 11, message :"")])
    }
    
    @IBAction func nameEditingChanged(_ sender: UITextFieldX) {
        if let id = nameTextField.text?.trimmingCharacters(in: .whitespaces), id.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func companyIDEditingChanged(_ sender: UITextFieldX) {
        if let id = companyIDTextField.text?.trimmingCharacters(in: .whitespaces), id.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    //MARK: Mobile
    @IBAction func mobileEditingChanged(_ sender: UITextFieldX) {
        if let mobile = mobileTextField.text?.trimmingCharacters(in: .whitespaces), mobile.isNotEmpty {
            self.mobileTextField.text = mobile
            let firstThree = mobile.prefix(3)
            if firstThree == "0" || firstThree == "01" || firstThree == "013" || firstThree == "014" || firstThree == "015" || firstThree == "016" || firstThree == "017" || firstThree == "018" || firstThree == "019" {
                self.isTextFieldNotEmpty = true
            } else {
                if mobile.count == 1 {
                    self.isTextFieldNotEmpty = false
                    self.mobileTextField.text = " "
                } else {
                    self.isTextFieldNotEmpty = false
                    self.mobileTextField.text = String(mobile.dropLast())
                }
            }
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func mobileEditingEnd(_ sender: UITextFieldX) {
        self.mobileTextField.text = mobileTextField.text?.trimmingCharacters(in: .whitespaces)
    }
    
    @IBAction func passwordEditingChanged(_ sender: UITextFieldX) {
        if let pass = passwordTextField.text?.trimmingCharacters(in: .whitespaces), pass.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func reTypePassEditingChanged(_ sender: UITextFieldX) {
        if let pass = retypePassTextField.text?.trimmingCharacters(in: .whitespaces), pass.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextFieldX) {
        if let id = emailTextField.text?.trimmingCharacters(in: .whitespaces), id.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func showHidePass(_ sender: UIButton) {
        passwordTextField?.isSecureTextEntry = !(passwordTextField?.isSecureTextEntry ?? false)
        if #available(iOS 13.0, *) {
            if !(passwordTextField?.isSecureTextEntry)! {
                showHidePass.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                showHidePass.setImage(UIImage(systemName: "eye"), for: .normal)
            }
        } else {
            // Fallback on earlier versions
            if !(passwordTextField?.isSecureTextEntry)! {
                showHidePass.setImage(UIImage(named: "password icon"), for: .normal)
            } else {
                showHidePass.setImage(UIImage(named: "password icon"), for: .normal)
            }
        }
    }
    
    @IBAction func showHideReTypePass(_ sender: UIButton) {
        retypePassTextField?.isSecureTextEntry = !(retypePassTextField?.isSecureTextEntry ?? false)
        
        if #available(iOS 13.0, *) {
            if !(retypePassTextField?.isSecureTextEntry)! {
                showHideRePass.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                showHideRePass.setImage(UIImage(systemName: "eye"), for: .normal)
            }
        } else {
            // Fallback on earlier versions
            if !(retypePassTextField?.isSecureTextEntry)! {
                showHideRePass.setImage(UIImage(named: "password icon"), for: .normal)
            } else {
                showHideRePass.setImage(UIImage(named: "password icon"), for: .normal)
            }
        }
    }
    
    @IBAction func didRegistered(_ sender: UIButtonX) {
        validator.validate(self)
    }

}


extension SignupViewController: ValidationDelegate {
    func validationSuccessful() {
        guard let name = self.nameTextField.text?.trim(), name.isValidName() else {
            showAlert(message: ValidationErrors.invalidName.description)
            return
        }
        
        guard let mobile = self.mobileTextField.text?.trim(), mobile.count == 11 else {
            showAlert(message: ValidationErrors.invalidMobile.description)
            return
        }
        
        guard let companyID = self.companyIDTextField.text?.trim() else {
            return
        }
        
        guard let password = self.passwordTextField.text?.trim() else {
            return
        }
        
        guard let reTypePassword = self.retypePassTextField.text?.trim(), password == reTypePassword else {
            showAlert(message: ValidationErrors.passwordNotMatched.description)
            return
        }
        
        guard let email = self.emailTextField.text?.trim(), email.isValidEmail() else {
            showAlert(message: ValidationErrors.invalidEmail.description)
            return
        }
        
        let isNowInBD = UserDefaults.standard.bool(forKey: AppConstants.keyIsLocatedInBD)
        let currentLocation = UserDefaults.standard.string(forKey: AppConstants.keyCurrentLocation) ?? ""
        
        if isNowInBD && currentLocation.isNotEmpty && currentLocation.contains(",") {
            let locationValues = currentLocation.components(separatedBy: ",")
            guard locationValues.count == 2, let lat = Double(locationValues[0]), let lon = Double(locationValues[1]) else {
                verifyLocationAndRegister(name: name, mobile:mobile, companyID:companyID, password:password, email: email)
                return
            }
            self.callRegistrationAPI(name: name, mobile:mobile, companyID:companyID, password:password, email: email, lat:lat, lon:lon)
        } else {
            verifyLocationAndRegister(name: name, mobile:mobile, companyID:companyID, password:password, email: email)
        }
        
        LocationManager.getLocation { (location) in
            if location.isInBangladesh == false {
                self.showAlert(message: ValidationErrors.outSideBD.description)
                return
            } else {
                UserDefaults.standard.set(true, forKey: AppConstants.keyIsLocatedInBD)
            }
            
            if location.error != nil {
                self.openLocationSettings()
                return
            }
            
            if let lat = location.lattitude, let lon = location.longitude {
                UserDefaults.standard.set("\(lat),\(lon)", forKey: AppConstants.keyCurrentLocation)
                self.callRegistrationAPI(name: name, mobile:mobile, companyID:companyID, password:password, email: email, lat:lat, lon:lon)
            } else {
                return
            }
        }
    }
    
    func verifyLocationAndRegister(name:String, mobile:String, companyID:String, password:String, email:String) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.getLocation { (location) in
                if location.isInBangladesh == false {
                    self.showAlert(message: ValidationErrors.outSideBD.description)
                    return
                }
                
                if location.error != nil {
                    self.openLocationSettings()
                    return
                }
                
                if let lat = location.lattitude, let lon = location.longitude {
                    self.callRegistrationAPI(name: name, mobile:mobile, companyID:companyID, password:password, email: email, lat:lat, lon:lon)
                } else {
                    return
                }
            }
        } else {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
    }
    
    func callRegistrationAPI(name:String, mobile:String, companyID:String, password:String, email:String, lat:Double, lon:Double) {
        self.progressHUD = ProgressHUDManager(view: self.view)
        guard let hud = self.progressHUD else {
            return
        }
        self.showLoading(hud: hud)
        
        APIServiceManager.register(mobile: mobile, name:name, companyID: companyID, password: password, email: email, lat: lat, lon: lon) { result in
            switch result {
            case .success(let value):
                self.showSuccessMessage(hud: hud, isNeedTowait: true, data: "", completion: nil)
            case .failure(let error):
                self.showFailedMessage(hud: hud, isNeedTowait: true, data: error.localizedDescription, completion: nil)
            }
        }
    }
}


