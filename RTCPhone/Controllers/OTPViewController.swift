//
//  OTPViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 8/12/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class OTPViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var resendOTPOutlet: UIButton!
    @IBOutlet weak var OTPNotificationOutlet: UILabel!
    var progressHUD: ProgressHUDManager?
    
    var mobileNo: String?
    var clientname: String?
    var isSuccessFullyReg: Bool = false
    var secrect: String?
    var username: String?
    var OTPNotificationMessage: String?
    var OTPCheckingForRegistration : Bool = false
    var otp: String?
    var msisdn: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self,
//                                       selector: #selector(LoginViewController.didRegistered(_:)),
//                                       name: CallStateNotificationName.registered.notificationName,
//                                       object: nil)
//        notificationCenter.addObserver(self,
//                                       selector: #selector(LoginViewController.failedRegistered(_:)),
//                                       name: CallStateNotificationName.failedRegistered.notificationName,
//                                       object: nil)
        

        // Do any additional setup after loading the view.
        OTPNotificationOutlet.text = OTPNotificationMessage
        //otpTextField.text = otp
        
        //TotalResendOTP = TotalResendOTP + 1;
        resendOTPOutlet.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        resendOTPOutlet.isEnabled = false
        
        self.startTimer()
    }
    
    @IBAction func didSubmitOTP(_ sender: UIButton? = nil) {
        
        self.progressHUD = ProgressHUDManager(view: self.view)
        self.progressHUD?.start()
        self.progressHUD?.isNeedShowSpinnerOnly = true
        otp = otpTextField.text?.trim()
        var para: [String:Any] = [:]
        //para["apikey"] = "81efa480098b0009cea8cd5a7dd5d1aa"
        para["msisdn"] = msisdn // new api key
        para["otp"] = otp
        para["secret"] = secrect
        
       // var msisdn: String, var otp: String, var secret: String
        
        // For Login
        var sendURL : String = "http://119.40.81.8/api/confirm"
        if OTPCheckingForRegistration {
            // For Registration
            sendURL = "http://119.40.81.8/api/confirm"
        }
        
        
        APIManager.requestWith(endUrl: sendURL, imageData: nil, parameters: para, onCompletion: { json in
            if let json = json {
                if let statuscode = json["statuscode"] as? String, statuscode != "200" {
                    let errorMessage = json["message"] as? String
                    //
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    if self.OTPCheckingForRegistration {
                        // For Registration
                        let alert = UIAlertController(title: "Successful", message: json["message"] as? String, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                            
//                            if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
//                                self.present(callVC, animated: true, completion: nil)
//                            }
                            self.OTPCheckingForRegistration = false
                            self.didSubmitOTP(nil)
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        // For Login
                            
                        if let data = json["data"] as? [String:Any],  let username = data["sip"] as? String,
                            let password = data["secret"] as? String, let server = data["domain"] as? String {
                            DispatchQueue.main.async {
                                
                                self.secrect = password
                                self.username = username
                                
                                let displayName = (data["displayName"] as? String) ?? ""
                                UserDefaults.standard.set(username, forKey: "username")
                                UserDefaults.standard.set(displayName, forKey: "displayName")
                                UserDefaults.standard.set(password, forKey: "password")
                                UserDefaults.standard.set(server, forKey: "server")
                                UserDefaults.standard.set(self.mobileNo, forKey: "mobileNo")
                                UserDefaults.standard.synchronize()
                                
                                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                                    print("appdelegate is missing")
                                    return
                                }
                                appdelegate.theLinphoneManager = CallReceivedManager()
                                
                                if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: username, password: password) {
                                    appdelegate.theLinphoneManager?.register(proxyConfig)
                                    appdelegate.theLinphoneManager?.setTimer()
                                }
                                
                            }
                        }
                        
                    }

                    
            }
            } else {
                // Server Error
                let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }, onError: { error in
             // Server Error
            let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
    var TotalResendOTP = 0;
    
    
    @IBAction func didResendOTP() {
        
        if let userID = msisdn  {
            
            TotalResendOTP = TotalResendOTP + 1;
            resendOTPOutlet.setTitleColor(UIColor.gray, for: UIControl.State.normal)
            resendOTPOutlet.isEnabled = false
            if TotalResendOTP > 5 {
                let alert = UIAlertController(title: "Error", message: "You have already attempt too many times", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.startTimer()
            
            self.progressHUD = ProgressHUDManager(view: self.view)
            self.progressHUD?.start()
            self.progressHUD?.isNeedShowSpinnerOnly = true
            
            
            var para: [String:Any] = [:]
            //para["apikey"] = "81efa480098b0009cea8cd5a7dd5d1aa"
            para["imei"] = UUID() // new api key
            para["msisdn"] = userID
            para["iccid"] = UUID()
            //para["clientname"] = fullNameTextField.text
            
            //var imei: String, var msisdn: String, var iccid: String
            
            APIManager.requestWith(endUrl: "http://119.40.81.8/api/register", imageData: nil, parameters: para, onCompletion: { json in
                
                if let json = json {
                    if let statuscode = json["statuscode"] as? String, statuscode != "200" {
                        self.progressHUD?.onSucceed()
                        
//                        let errorMessage = json["message"] as? String
//                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
                        
                    } else if let data = json["data"] as? [String:Any], let otp = data["otp"] as? String, let secret = data["secret"] as? String {
                        self.progressHUD?.onSucceed()
                        
//                        if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController {
                            //callVC.mobileNo = userID
                           // callVC.otp = otp
                            self.secrect = secret
                            //callVC.msisdn = userID
                            //callVC.OTPNotificationMessage = json["message"] as? String
                           // self.present(callVC, animated: true, completion: nil)
                       // }
                    } else {
                        self.progressHUD?.onSucceed()
                        // Server Error
//                        let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.progressHUD?.onSucceed()
                    // Server Error
//                    let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                }
                
                
                
            }, onError: { error in
                self.progressHUD?.onSucceed()
                // Server Error
//                let alert = UIAlertController(title: "Error", message: "Server Error", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
            })
            
            //            if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: userID, password: pass) {
            //               appdelegate.theLinphoneManager?.register(proxyConfig)
            //               appdelegate.theLinphoneManager?.setTimer()
            //            }
            
            //            UserDefaults.standard.set(userID, forKey: "username")
            //            UserDefaults.standard.set(pass, forKey: "password")
            //            UserDefaults.standard.synchronize()
            //
            //            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            //            let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
            //            NavigationManager.setViewController(mainTabbarVC!, left: true)
            
        }
        
    }
    
//    @IBAction func didResendOTP1(_ sender: UIButton) {
//        
//        //resendOTPOutlet.setTitleColor(UIColorFromRGB("CCCCCC"), forState: .Normal)
//        // Can Resend OTP Only 5 times
//        //print("didResendOTP \(TotalResendOTP)")
//        TotalResendOTP = TotalResendOTP + 1;
//        resendOTPOutlet.setTitleColor(UIColor.gray, for: UIControl.State.normal)
//        resendOTPOutlet.isEnabled = false
//        if TotalResendOTP > 5 {
//            let alert = UIAlertController(title: "Error", message: "You have already attempt too many times", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//           return
//        }
//        
//        self.startTimer()
//        
//        var para: [String:Any] = [:]
//        //para["apikey"] = "81efa480098b0009cea8cd5a7dd5d1aa"
//        para["apikey"] = "QW1CRXJQam9oZW5uQ0NIOTg0NDkzSEhAQCNDSEhNZ2dteX" // new api key
//        para["mobileno"] = mobileNo ?? ""
//        para["clientname"] = clientname ?? ""
//        
//        // For Login
//        var sendURL : String = "https://amberphone.amberit.com.bd/amberphoneapi/login.php"
//        if OTPCheckingForRegistration {
//            // For Registration
//            sendURL = "https://amberphone.amberit.com.bd/amberphoneapi/registrationStage01.php"
//        }
//        
//        APIManager.requestWith(endUrl: sendURL, imageData: nil, parameters: para, onCompletion: { json in
//            
//            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
//                
//                print("appdelegate is missing")
//                return
//            }
//            
//            if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: "userID", password: "pass") {
//                appdelegate.theLinphoneManager?.register(proxyConfig)
//                appdelegate.theLinphoneManager?.setTimer()
//            }
////            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
////            let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
////            NavigationManager.setViewController(mainTabbarVC!, left: true)
//            
//        }, onError: { error in
//            
//        })
//        
//    }
    
    @objc func failedRegistered(_ sender: NSNotification) {
        DispatchQueue.main.async {
//            self.progressHUD?.isNeedShowSpinnerOnly = false
//            self.progressHUD?.isNeedShowImage = true
//            self.progressHUD?.isNeedWaitForUserAction = true
//            self.progressHUD?.failledMessage = "User not found"
//            self.progressHUD?.onFailed()
        }
    }
    
    @objc func didRegistered(_ sender: NSNotification) {
        // DispatchQueue.main.async {
            if self.isSuccessFullyReg == true {
                return
            }
           if let userID = self.username , let pass = self.secrect {
        
//            self.progressHUD?.isNeedShowSpinnerOnly = true
//            self.progressHUD?.isNeedWaitForUserAction = false
//            self.progressHUD?.onSucceed()
            self.isSuccessFullyReg = true
            UserDefaults.standard.set(userID, forKey: "username")
            UserDefaults.standard.set(pass, forKey: "password")
            UserDefaults.standard.set(pass, forKey: "password")
            UserDefaults.standard.synchronize()
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController
            NavigationManager.setViewController(mainTabbarVC!, left: true)
            //}
          }
        //}
    }
    var timerStartTime:Date?
    var otpInputCount = 0
    var timer: Timer?
    
    func startTimer() {
       // otpInputCount = 0
        timeLabel.text = ""
        timerStartTime = Date()
        timer = Timer.every(1.second) {
            DispatchQueue.main.async {
                let timeNow = Date()
                if let startTime = self.timerStartTime {
                    let timediff = 60  - timeNow.timeIntervalSince(startTime).seconds
                     self.timeLabel.text =  String(format: "%.0f", abs(timediff)) + " Seconds"
                    if timediff <= 0.0 {
                        //timer.in
                        //self.isExpired = true
                        self.timeLabel.text = ""
                        self.timer?.invalidate()
                        self.resendOTPOutlet.setTitleColor(UIColor.blue, for: UIControl.State.normal)
                        self.resendOTPOutlet.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        
        if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
            self.present(callVC, animated: true, completion: nil)
        }
        //self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
