/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CallKit
import UIKit


struct IncomingCallInfo {
    var uuid: String?
    var callerName: String?
    var callerID:String?
    var callStatus: IncomingCallState?
}

class CallManager {
    
    static var currentIncomingCall: IncomingCallInfo?
    
    class func sendDTMF(digit: Int8) {
        linphone_call_send_dtmf(linphone_core_get_current_call(theLinphone.lc), digit)
        linphone_core_play_dtmf(theLinphone.lc, digit, 100);
    }
    
    class func presentReceivedCall(phoneNumber: String) {
        if AppGlobalValues.isCallOngoing {
            acceptReceivedCall()
            AppGlobalValues.conferenceNumber = phoneNumber
        } else {
            if let window = UIApplication.shared.keyWindow, let currentVC = window.rootViewController {
                if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                    callVC.phoneNumberOfuser = phoneNumber
                    callVC.callDialType = .received
                    callVC.modalPresentationStyle = .fullScreen
                    currentVC.present(callVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    class func presentReceivedCall(fromVC: UIViewController, phoneNumber: String, isFromMainVCApear: Bool = false) {
       // if let window = UIApplication.shared.keyWindow, let currentVC = window.rootViewController {
        if AppGlobalValues.isCallOngoing {
            AppGlobalValues.conferenceNumber = phoneNumber
        } else {
            if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                callVC.phoneNumberOfuser = phoneNumber
                callVC.isFromMainVCApear = isFromMainVCApear
                callVC.callDialType = .received
                callVC.modalPresentationStyle = .fullScreen

                fromVC.present(callVC, animated: true, completion: nil)
            }
        }
        //}
    }
    
    class func acceptReceivedCall() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("appdelegate is missing")
            return
        }
        //appdelegate.callManager.end(call: (appdelegate.providerDelegate?.answerCall)!)
        appdelegate.theLinphoneManager?.acceptCall()
    }
    
    class func endReceivedCall() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("appdelegate is missing")
            return
        }
        //appdelegate.callManager.end(call: (appdelegate.providerDelegate?.answerCall)!)
        appdelegate.theLinphoneManager?.endCall()
        if let callID = appdelegate.providerDelegate?.callID {
            appdelegate.providerDelegate?.provider.reportCall(with: callID, endedAt: nil, reason: .answeredElsewhere)
        }
        appdelegate.providerDelegate?.isCallReceivedFromBacground = false
        appdelegate.providerDelegate?.incomingCall = nil
    }
}

class ConferenceCallManager {
  
    var lc: OpaquePointer? =  theLinphone.lc
    var lct: LinphoneCoreVTable?
    var confCalls: [RTCLinphoneCall] = []
    var iterateTimer: Timer?
    //var linphoneManager: LinphoneManager?
    var call: RTCLinphoneCall?
    
    init() {
        //linphoneManager = LinphoneManager()
       
    }
    
    func makeConferencePhoneCall(calleeAccounts: [String]) {
        
//        guard let _ = setIdentify() else {
//            print("no identity")
//            return;
//        }
        
        for calleeAccount in calleeAccounts {
            //DispatchQueue.main.async {
//            if let ccall = self.confCalls.first {
//                linphone_call_pause(ccall.call!);
//            }
                 self.call = RTCLinphoneCall()
                Thread.sleep(until: Date().addingTimeInterval(1))
                self.call?.makeCall(calleeAccount: calleeAccount)
            
                self.confCalls.append(self.call!)
            //
        }
          
            //Thread.sleep(until: Date().addingTimeInterval(1))
        
        //linphone_core_enter_conference(
//        setTimer()
//        idle()
        linphone_core_add_all_to_conference(theLinphone.lc)
       
        //confCalls.first?.setTimer()
    }
    
    func idle(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
        //        shutdown()
    }
    
    
    
    func shutdown(){
        NSLog("Shutdown..")
        //isCalledEnded = true
        iterateTimer?.invalidate()
        iterateTimer?.invalidate()
        iterateTimer = nil
        let proxy_cfg = linphone_core_get_default_proxy_config(lc); /* get default proxy config*/
        linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /*de-activate registration for this proxy config*/
        linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
        while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
            linphone_core_iterate(lc); /*to make sure we receive call backs before shutting down*/
            ms_usleep(50000);
        }
        
        linphone_core_destroy(lc);
    }
    
    @objc func iterate(){
        if let lc = lc {
            //if !isCalledEnded {
            linphone_core_iterate(lc); /* first iterate initiates registration */
            //}
        }
    }
    
    func setTimer(){
        iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }

    
    func setIdentify() -> OpaquePointer? {
        
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
        //let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        //let dict = NSDictionary(contentsOfFile: path!)
        //        let account = "0203600005"
        //        let password = "3423"
        //        let domain = "164.160.4.89"
        
        var account = "09611677128"
        var password = "rTchY0ubs!p"
        var domain = "202.4.97.11"
        
        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String, let server = UserDefaults.standard.value(forKey: "server") as? String {
            account = userID
            password = pass
            domain = server
        }
        
        let identity = "sip:" + account + "@" + domain;
        
        
        /*create proxy config*/
        let proxy_cfg = linphone_proxy_config_new();
        
        /*parse identity*/
        let from = linphone_address_new(identity);
        
        if (from == nil){
            NSLog("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org");
            return nil
        }
        
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil); /*create authentication structure from identity*/
        linphone_core_add_auth_info(lc, info); /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        //linphone_proxy_config_set_conference_factory_uri(proxy_cfg, identity);
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        //linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, domain); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(lc, proxy_cfg); /*set to default proxy*/
        
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_set_conference_factory_uri(proxy_cfg, "sip:conference-factory@sip.linphone.org");
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
    }

}

class CallReceivedManager {
    
    var lc: OpaquePointer? = theLinphone.lc
    var lct: LinphoneCoreVTable?
    var confCalls: [RTCLinphoneCall] = []
    var iterateTimer: Timer?
    var isTimerStarted: Bool = false
    
    var stopTimer: Bool = false {
        
        didSet {
            print("Start")
        }
    }
    
    var receivedCallAccepted: ((Bool)->Void)?
    var call : Optional<OpaquePointer>?
    var account: String = "09611677128"
    var password: String = "rTchY0ubs!p"
    var domain: String = "202.4.97.11"
    
    init() {
        
        lct = LinphoneCoreVTable()
        //isCalledEnded = false
        
        // Enable debug log to stdout
        linphone_core_set_log_file(nil)
        linphone_core_set_log_level(BctbxLogLevel(rawValue: BctbxLogLevel.RawValue(CTL_DEBUG)))
        
        // Load config
        let configFilename = documentFile("linphonerc222")
        let factoryConfigFilename = bundleFile("linphonerc-factory")
        
        let configFilenamePtr: UnsafePointer<Int8> = configFilename.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr: UnsafePointer<Int8> = factoryConfigFilename.cString(using: String.Encoding.utf8.rawValue)!
        let lpConfig = linphone_config_new_with_factory(configFilenamePtr, factoryConfigFilenamePtr)
        
        // Set Callback
        lct?.registration_state_changed = registrationStateChanged
        lct?.call_state_changed = callStateChanged
        
        if lc == nil {
            lc = linphone_core_new_with_config(&lct!, lpConfig, nil)
            theLinphone.lc = lc
        }
        
        // Set ring asset
        let ringbackPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/ringback.wav").absoluteString
        linphone_core_set_ringback(lc, ringbackPath)

        let localRing = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/\(UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone)  ?? "Sounds/toy-mono.wav")").absoluteString
        linphone_core_set_ring(lc, localRing)
        
    }
    func makePhoneCall(calleeAccount: String) {
       // let calleeAccount = "+8801710441906"
        
//        guard let _ = setIdentify() else {
//            print("no identity")
//            return;
//        }
        call = linphone_core_invite(theLinphone.lc, calleeAccount)
        //iterateTimer?.invalidate()
        //setTimer()
       // idle()
    }
    func setIdentify(account : String, password: String) -> OpaquePointer? {
        
        //        self.account = account
        //        self.password = password
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
        if let server = UserDefaults.standard.value(forKey: "server") as? String {
            domain = server
        }
        
        let identity = "sip:" + account + "@" + domain;
        
        /*create proxy config*/
        let proxy_cfg = linphone_proxy_config_new();
    
        /*parse identity*/
        let from = linphone_address_new(identity);
        
        if (from == nil){
            NSLog("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org");
            return nil
        }
        
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil); /*create authentication structure from identity*/
        linphone_core_add_auth_info(lc, info); /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, domain); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(lc, proxy_cfg); /*set to default proxy*/
        
        
        return proxy_cfg!
    }
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    func startReceivingCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        stopTimer = false
        setTimer()
    }
    
    func idle(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
        //        shutdown()
    }
    
    func endCall() {
            if let callReceived = theLinphone.callReceived {
                linphone_core_terminate_call(lc,callReceived);
               
                //linphone_call_unref(callReceived);
                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                    print("appdelegate is missing")
                    return
                }
                if let call = appdelegate.providerDelegate?.incomingCall {
                    appdelegate.callManager.end(call: call)
                    appdelegate.providerDelegate?.incomingCall = nil
                }
                if let call = appdelegate.providerDelegate?.answerCall {
                     appdelegate.callManager.end(call: call)
                    appdelegate.providerDelegate?.answerCall = nil
                }
                theLinphone.callReceived = nil
//                if let receivedCallManager = appdelegate.theLinphoneManager, let proxyConfig = receivedCallManager.setIdentify() {
//                    appdelegate.theLinphoneManager?.shutdown()
//                    appdelegate.theLinphoneManager?.register(proxyConfig)
//                    appdelegate.theLinphoneManager?.setTimer()
//                }
            }
    }
    
    func acceptCall() {
        if let callReceived = theLinphone.callReceived {
           linphone_core_accept_call(lc, callReceived)
           //receivedCallAccepted?(true)
        }
    }
    
   

    
    func shutdown(){
        NSLog("Shutdown..")
        if lc == nil {
            return
        }
        //isCalledEnded = true
        iterateTimer?.invalidate()
        iterateTimer = nil
        stopTimer = true
        let proxy_cfg = linphone_core_get_default_proxy_config(lc); /* get default proxy config*/
        linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /*de-activate registration for this proxy config*/
        linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
       
        while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
            linphone_core_iterate(lc); /*to make sure we receive call backs before shutting down*/
            ms_usleep(50000);
        }
       
        linphone_core_destroy(theLinphone.lc);
       // lc = nil
        NotificationCenter.default.post(name: CallStateNotificationName.failedRegistered.notificationName, object: nil)

    }
    
    @objc func iterate(){
        if let lc = lc, !stopTimer {
            //if !isCalledEnded {
            linphone_core_iterate(lc); /* first iterate initiates registration */
            //}
        }
    }
    
    func setTimer(){
        isTimerStarted = true
        iterateTimer = Timer.scheduledTimer(
        timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
    
    
    func setIdentify() -> OpaquePointer? {
        
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
        //let path = Bundle.main.path(forResource: "Secret", ofType: "plist")
        //let dict = NSDictionary(contentsOfFile: path!)
        //        let account = "0203600005"
        //        let password = "3423"
        //        let domain = "164.160.4.89"
        
        var account = "09611677128"
        var password = "rTchY0ubs!p"
        var domain = "202.4.97.11"
        
        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String, let server = UserDefaults.standard.value(forKey: "server") as? String {
            account = userID
             password = pass
            domain = server
        }
        
        let identity = "sip:" + account + "@" + domain;
        
        
        /*create proxy config*/
        let proxy_cfg = linphone_proxy_config_new();
        
        /*parse identity*/
        let from = linphone_address_new(identity);
        
        if (from == nil){
            NSLog("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org");
            return nil
        }
 
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil); /*create authentication structure from identity*/
        linphone_core_add_auth_info(lc, info); /*add authentication info to LinphoneCore*/
        linphone_address_set_port(from, 5070)
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        //linphone_proxy_config_set_conference_factory_uri(proxy_cfg, identity);
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        //linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, domain); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(lc, proxy_cfg); /*set to default proxy*/
        
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_set_conference_factory_uri(proxy_cfg, "sip:conference-factory@sip.linphone.org");
        linphone_proxy_config_enable_register(proxy_cfg, 1); /* activate registration for this proxy config*/
    }
    
}

