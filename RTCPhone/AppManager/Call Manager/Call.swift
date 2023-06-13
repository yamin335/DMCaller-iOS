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
import UIKit

enum CallState {
  case connecting
  case active
  case held
  case ended
}

enum ConnectedState {
  case pending
  case complete
}

let registrationStateChanged: LinphoneCoreRegistrationStateChangedCb  = {
    (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: _LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in
    
    // print(message)
    
    switch state{
    case LinphoneRegistrationNone: /**<Initial state for registrations */
        NSLog("LinphoneRegistrationNone")
        
    case LinphoneRegistrationProgress:
        NSLog("Connecting")
        NotificationCenter.default.post(name:  CallStateNotificationName.callConnecting.notificationName, object: nil)
    case LinphoneRegistrationOk:
        NSLog("Ringing")
        //self.delegate.callRinging()
          NotificationCenter.default.post(name:  CallStateNotificationName.registered.notificationName, object: nil)
        
        
    case LinphoneRegistrationCleared:
        NSLog("End")
        NotificationCenter.default.post(name: CallStateNotificationName.callDidEnd.notificationName, object: nil)
        
    case LinphoneRegistrationFailed:
        NotificationCenter.default.post(name: CallStateNotificationName.failedRegistered.notificationName, object: nil)
        
    default:
        NSLog("Unkown registration state")
    }
    } as LinphoneCoreRegistrationStateChangedCb

let callStateChanged: LinphoneCoreCallStateChangedCb = {
    (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, callSate: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in
    
    switch callSate {
    case LinphoneCallStateIncomingReceived: /**<This is a new incoming call */
        NSLog("callStateChanged: LinphoneCallIncomingReceived")
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
//        if answerCall{
//            ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
//            linphone_core_accept_call(lc, call)
//        }
        theLinphone.callReceived = call
        
       // let callLog = linphone_call_get_remote_address_as_string(call)
       // let name =  String(data: linphone_call_log_get_call_id(callLog), encoding: String.Encoding.utf8 )
        var  name = "Unknown Number"
        //linphone_call_log_get_user_pointer(callLog)
       // NSString(data: linphone_call_log_get_call_id(callLog), encoding: . )
       // NSString *callId = [NSString stringWithUTF8String:callLog];
        if let phoneNumber = NSString(utf8String:linphone_call_get_remote_address_as_string(call)), let phNum = phoneNumber as? String, let actualNum = phNum.split(separator: " ").first {
        name = """
            \(actualNum)
            """.replacingOccurrences(of: "\"", with: "")
        }
            UserDefaults.standard.set(true, forKey: "isauto")
            UserDefaults.standard.synchronize()
        
        let state = UIApplication.shared.applicationState
        if state == .background {
            theLinphone.callReceived = call
            NotificationCenter.default.post(name: CallStateNotificationName.receivedCallInBG.notificationName, object: nil)
        } else {
            theLinphone.callReceived = call
            NotificationCenter.default.post(name: CallStateNotificationName.receivedCallInBG.notificationName, object: nil)
        }
       
    case LinphoneCallStateStreamsRunning: /**<The media streams are established and running*/
        NSLog("callStateChanged: LinphoneCallStreamsRunning")
        NotificationCenter.default.post(name:  CallStateNotificationName.callDidAnswer.notificationName, object: call)
        
    case is LinphoneCallDir: /**<The call encountered an error*/
        NSLog("callStateChanged: LinphoneCallError")
        
        //            LinphoneCallIncomingReceived,
        //            LinphoneCallOutgoingInit,
    //            LinphoneCallOutgoingProgress,
    case  LinphoneCallStateOutgoingRinging :
        NSLog("LinphoneCallOutgoingRinging")
        NotificationCenter.default.post(name: CallStateNotificationName.callRinging.notificationName, object: call)
        
    case  LinphoneCallStateOutgoingProgress :
        NSLog("LinphoneCallOutgoingProgress")
        NotificationCenter.default.post(name:  CallStateNotificationName.callConnecting.notificationName, object: nil)
    case LinphoneCallStateEnd:
        NotificationCenter.default.post(name: CallStateNotificationName.callDidEnd.notificationName, object: nil)
        
    case LinphoneCallStateReleased:
        NSLog("LinphoneCallStateReleased")
        NotificationCenter.default.post(name: CallStateNotificationName.callDidEnd.notificationName, object: nil)
        if  theLinphone.callReceived != nil {
           CallManager.endReceivedCall()
        }
    default:
        NSLog("Default call state")
    }
}

public class RTCLinphoneCall {
    
    

    var lc: OpaquePointer?
    var lct: LinphoneCoreVTable?
    var call : Optional<OpaquePointer>?
     var iterateTimer: Timer?
    
    init() {
//
        lct = LinphoneCoreVTable()
//        isCalledEnded = false
//
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
//
//
        if theLinphone.lc == nil {
        lc = linphone_core_new_with_config(&lct!, lpConfig, nil)
        } else {
           lc = theLinphone.lc
        }
        // Set ring asset
       
        let ringbackPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/ringback.wav").absoluteString
        linphone_core_set_ringback(lc, ringbackPath)

        let localRing = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/\(UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone)  ?? "Sounds/toy-mono.wav")").absoluteString
        linphone_core_set_ring(lc, localRing)
        
        guard let _ = setIdentify() else {
            print("no identity")
            return;
        }
        
    }
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    func makeCall(calleeAccount: String) {
        
//        guard let proxyConfig = setIdentify() else {
//            print("no identity")
//            return;
//        }
        //linphone_core_preempt_sound_resources(lc);
        call = linphone_core_invite(lc, calleeAccount)
        //register(proxyConfig)
        setTimer()
        //idle()
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
        
        linphone_proxy_config_set_server_addr(proxy_cfg, server_addr); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(lc, proxy_cfg); /*set to default proxy*/
        linphone_proxy_config_set_conference_factory_uri(proxy_cfg, "sip:conference-factory@sip.linphone.org");
        
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
        linphone_proxy_config_set_conference_factory_uri(proxy_cfg, "sip:conference-factory@sip.linphone.org");
    }

    
}
