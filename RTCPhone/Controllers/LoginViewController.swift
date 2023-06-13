//
//  LoginViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import INTULocationManager

class LoginViewController: UIViewController {

    @IBOutlet weak var mobileTextField: UITextFieldX!
    @IBOutlet weak var passwordTextField: UITextFieldX!
    
    @IBOutlet weak var showPassIcon: UIButton!
    @IBOutlet weak var loginButton: UIButtonX!
    
    var progressHUD: ProgressHUDManager?
    let validator = Validator()
  
    var userMobile = ""
    var userPassword = ""
    var isTextFieldNotEmpty: Bool = false {
        didSet{
            if isTextFieldNotEmpty == true {
                if let mobile = mobileTextField.text, let password = passwordTextField.text,  mobile.isNotEmpty, password.isNotEmpty {
                    loginButton.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
                    loginButton.isEnabled = true
                } else {
                    loginButton.backgroundColor = UIColor.lightGray
                    //loginButton.isEnabled = false
                }
            } else {
                loginButton.backgroundColor = UIColor.lightGray
                //loginButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        
        if let userID = UserDefaults.standard.string(forKey: "username"),
            let pass = UserDefaults.standard.string(forKey: "password") {
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            if !userID.isEmpty && !pass.isEmpty && isLoggedIn {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
                NavigationManager.setViewController(mainTabbarVC!, left: true)
            }
        }
        
        self.isTextFieldNotEmpty = false
        //Dummy acc for dev
//        mobileTextField.text = "01710441906"
//        passwordTextField.text = "bdcom906"
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            
        })
        
        //MobileNumberRule(),
        validator.registerField(mobileTextField, errorLabel: nil, rules: [MaxLengthRule(length: 11, message :"")])
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func companyIDDidEditingChanged(_ sender: UITextFieldX) {
//        if let id = companyIDTextField.text?.trimmingCharacters(in: .whitespaces), id.isNotEmpty {
//            self.isTextFieldNotEmpty = true
//        } else {
//            self.isTextFieldNotEmpty = false
//        }
    }
    
    @IBAction func mobileDidEditingChanged(_ sender: UITextFieldX) {
        if let mobile = mobileTextField.text?.trimmingCharacters(in: .whitespaces), mobile.isNotEmpty { //, mobile.count == 11
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
    
    @IBAction func passwordDidEditingChanged(_ sender: UITextFieldX) {
        if let pass = passwordTextField.text?.trimmingCharacters(in: .whitespaces), pass.isNotEmpty {
            self.isTextFieldNotEmpty = true
        } else {
            self.isTextFieldNotEmpty = false
        }
    }
    
    @IBAction func showPasswordAction(_ sender: UIButton) {
        passwordTextField?.isSecureTextEntry = !(passwordTextField?.isSecureTextEntry ?? false)
        if #available(iOS 13.0, *) {
            if !(passwordTextField?.isSecureTextEntry)! {
                showPassIcon.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                showPassIcon.setImage(UIImage(systemName: "eye"), for: .normal)
            }
        } else {
            // Fallback on earlier versions
            if !(passwordTextField?.isSecureTextEntry)! {
                showPassIcon.setImage(UIImage(named: "password icon"), for: .normal)
            } else {
                showPassIcon.setImage(UIImage(named: "password icon"), for: .normal)
            }
        }
    }
    
    @IBAction func loginClicked(_ sender: UIButtonX) {
        validator.validate(self)
    }
    
    @IBAction func registrationClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let passwordVC = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as?  SignupViewController
        self.navigationController?.show(passwordVC!, sender: self)
    }
    

}

extension LoginViewController: ValidationDelegate {
    func validationSuccessful() {
        guard let mobile = self.mobileTextField.text, mobile.count == 11 else {
            showAlert(message: ValidationErrors.invalidMobile.description)
            return
        }
        
//        guard let companyID = self.companyIDTextField.text else {
//            return
//        }
        
        guard let password = self.passwordTextField.text else {
            return
        }
        
        let isNowInBD = UserDefaults.standard.bool(forKey: AppConstants.keyIsLocatedInBD)
        let currentLocation = UserDefaults.standard.string(forKey: AppConstants.keyCurrentLocation) ?? ""
        
        if isNowInBD && currentLocation.isNotEmpty && currentLocation.contains(",") {
            let locationValues = currentLocation.components(separatedBy: ",")
            guard locationValues.count == 2, let lat = Double(locationValues[0]), let lon = Double(locationValues[1]) else {
                verifyLocationAndRequestLogin(mobile: mobile, password: password)
                return
            }
            self.callLoginAPI(mobile: mobile, companyID: AppManager.companyID, password: password, lat:lat, lon:lon)
        } else {
            verifyLocationAndRequestLogin(mobile: mobile, password: password)
        }
    }
    
    func verifyLocationAndRequestLogin(mobile: String, password: String) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
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
                    self.callLoginAPI(mobile: mobile, companyID: AppManager.companyID, password: password, lat:lat, lon:lon)
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
    
    func callLoginAPI(mobile: String, companyID: String, password: String, lat: Double, lon: Double) {
        self.progressHUD = ProgressHUDManager(view: self.view)
        guard let hud = self.progressHUD else {
            return
        }
        self.showLoading(hud: hud)
        
        APIServiceManager.login(mobile: mobile, companyID: companyID,
                                password: password, uuid: UUID().uuidString,
                                lat: lat, lon: lon) { result in
            switch result {
            case .success(let value):
                if let userID = value.extensions, let pass = value.secret, let server = value.server_ip {
                    UserDefaults.standard.set(mobile, forKey: "mobileNo")
                    UserDefaults.standard.set(userID, forKey: "username")
                    UserDefaults.standard.set(pass, forKey: "password")
                    UserDefaults.standard.set(server, forKey: "server")
                    UserDefaults.standard.set(value.name, forKey: "displayName")
                    UserDefaults.standard.set(value.company_uniqueid, forKey: "companyUniqueID")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.synchronize()
                    
                    guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                        print("appdelegate is missing")
                        return
                    }
                    
                    if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
                    let requestBody = FCMTokenRegisterRequest(
                        userid: AppManager.userID,
                        apikey: APIConfiguration.apiKEY,
                        mobile_no: mobile,
                        company: AppManager.companyID,
                        token: deviceToken, imei_number: UUID().uuidString,
                        latitude: lat, longitude: lon, platform: AppManager.platform)
                        appdelegate.registerFCMToken(requestBody: requestBody)
                    } else {
                        return
                    }
                   
                    appdelegate.theLinphoneManager = CallReceivedManager()
                    
                    if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: userID, password: pass) {
                        appdelegate.theLinphoneManager?.register(proxyConfig)
                        appdelegate.theLinphoneManager?.setTimer()
                    }
                    
                    self.succeessWithEndLoading(hud: hud) {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
                        NavigationManager.setViewController(mainTabbarVC!, left: false)
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.showFailedMessage(hud: hud, isNeedTowait: true, data: "Invalid credentials! Please try again.", completion: nil)
                }
                
            case .failure(let error):
                self.showFailedMessage(hud: hud, isNeedTowait: true, data: error.localizedDescription, completion: nil)
            }
        }
    }
}


////
////  LoginViewController.swift
////  RTCPhone
////
////  Created by Mamun Ar Rashid on 1/7/18.
////  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
////
//
//import UIKit
//import INTULocationManager
//
//class LoginViewController: UIViewController, UITextFieldDelegate {
//
//    @IBOutlet weak var userIDTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    var progressHUD: ProgressHUDManager?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String {
//            if !userID.isEmpty && !pass.isEmpty {
//                guard (UIApplication.shared.delegate as? AppDelegate) != nil else {
//                    print("appdelegate is missing")
//                    return
//                }
////                appdelegate.theLinphoneManager = CallReceivedManager()
////                let proxyConfig = appdelegate.theLinphoneManager?.startReceivingCall
//
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
//                NavigationManager.setViewController(mainTabbarVC!, left: true)
//            }
//        }
//
////        addLeftImageTo(textField: userIDTextField, andImage: UIImage(named: "user icon")!)
////        addLeftImageTo(textField: passwordTextField, andImage: UIImage(named: "password icon")!)
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
//        self.view.addGestureRecognizer(tapGesture)
//        userIDTextField.delegate = self
//
////        let notificationCenter = NotificationCenter.default
////        notificationCenter.addObserver(self,
////                                       selector: #selector(LoginViewController.didRegistered(_:)),
////                                       name: CallStateNotificationName.registered.notificationName,
////                                       object: nil)
////        notificationCenter.addObserver(self,
////                                       selector: #selector(LoginViewController.failedRegistered(_:)),
////                                       name: CallStateNotificationName.failedRegistered.notificationName,
////                                       object: nil)
//
//
//    }
//
//    @objc func failedRegistered(_ sender: NSNotification) {
//        DispatchQueue.main.async {
//            self.progressHUD?.isNeedShowSpinnerOnly = false
//            self.progressHUD?.isNeedShowImage = true
//            self.progressHUD?.isNeedWaitForUserAction = true
//            self.progressHUD?.failledMessage = "User not found"
//            self.progressHUD?.onFailed()
//        }
//    }
//
//    @objc func didRegistered(_ sender: NSNotification) {
//       // DispatchQueue.main.async {
//            if let userID = self.userIDTextField.text , let pass = self.passwordTextField.text {
//
//                self.progressHUD?.isNeedShowSpinnerOnly = true
//                self.progressHUD?.isNeedWaitForUserAction = false
//                self.progressHUD?.onSucceed()
//
//                UserDefaults.standard.set(userID, forKey: "username")
//                UserDefaults.standard.set(pass, forKey: "password")
//                UserDefaults.standard.synchronize()
//
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
//                NavigationManager.setViewController(mainTabbarVC!, left: true)
//                //}
//            }
//        //}
//    }
//
//    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
//        userIDTextField.resignFirstResponder()
//        passwordTextField.resignFirstResponder()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//
//
//
//    @IBAction func loginClicked() {
//
//        if let userID = userIDTextField.text  {
//
//            if userID.isEmpty {
//               return
//            }
//
//            if (userIDTextField.text?.count)! < 11 {
//                return
//            }
//
//
//            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
//
//                print("appdelegate is missing")
//                return
//            }
//
//            self.progressHUD = ProgressHUDManager(view: self.view)
//            self.progressHUD?.start()
//            self.progressHUD?.isNeedShowSpinnerOnly = true
//
//
//            var para: [String:Any] = [:]
//            //para["apikey"] = "81efa480098b0009cea8cd5a7dd5d1aa"
//            para["imei"] = UUID() // new api key
//            para["msisdn"] = userID
//            para["iccid"] = UUID()
//            //para["clientname"] = fullNameTextField.text
//
//            //var imei: String, var msisdn: String, var iccid: String
//
//            APIManager.requestWith(endUrl: "http://119.40.81.8/api/register", imageData: nil, parameters: para, onCompletion: { json in
//
//                if let json = json {
//                    if let statuscode = json["statuscode"] as? String, statuscode != "200" {
//                        self.progressHUD?.onSucceed()
//
//                        let errorMessage = json["message"] as? String
//                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//
//                    } else if let data = json["data"] as? [String:Any], let secret = data["secret"] as? String {
//                        self.progressHUD?.onSucceed()
//
//                        if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
//                            callVC.mobileNo = userID
//                            //callVC.otp = otp
//                            callVC.secrect = secret
//                            callVC.msisdn = userID
//                            callVC.OTPNotificationMessage = json["message"] as? String
//                            self.present(callVC, animated: true, completion: nil)
//                        }
//                    } else {
//                        self.progressHUD?.onSucceed()
//                        // Server Error
//                        let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                } else {
//                    self.progressHUD?.onSucceed()
//                    // Server Error
//                    let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//
//
//
//            }, onError: { error in
//                self.progressHUD?.onSucceed()
//                // Server Error
//                let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            })
//
////            if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: userID, password: pass) {
////               appdelegate.theLinphoneManager?.register(proxyConfig)
////               appdelegate.theLinphoneManager?.setTimer()
////            }
//
////            UserDefaults.standard.set(userID, forKey: "username")
////            UserDefaults.standard.set(pass, forKey: "password")
////            UserDefaults.standard.synchronize()
////
////            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
////            let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
////            NavigationManager.setViewController(mainTabbarVC!, left: true)
//
//        }
//
//    }
//
//
//    func textField(_ userIDTextField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 11
//        let currentString: NSString = userIDTextField.text! as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        //theLinphoneManager?.shutdown()
//        super.viewDidDisappear(animated)
//    }
//
//    func addLeftImageTo(textField: UITextField, andImage image: UIImage) {
//        let leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        leftImageView.image = image
//        textField.leftView = leftImageView
//        textField.leftViewMode = .always
//    }
//
//}
