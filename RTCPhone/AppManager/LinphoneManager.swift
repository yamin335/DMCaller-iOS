import Foundation
 import  UIKit

var answerCall: Bool = true

struct theLinphone {
    static var lc: OpaquePointer?
    static var lct: LinphoneCoreVTable?
    static var manager: LinphoneManager?
    static var callReceived: Optional<OpaquePointer>?
    
}

public enum CallStateNotificationName : String {
    case callDidAnswer = "callDidAnswer"
    case callDidEnd = "callDidEnd"
    case callDidFail =  "callDidFail"
    case callConnecting = "callConnecting"
    case callRinging = "callRinging"
    case callConected = "callConected"
    case registered = "registered"
    case failedRegistered = "failedRegistered"
    case receivedCallInBG = "receivedCallInBG"
    case receivedCallInBGInActve = "receivedCallInBGInActve"
    
    var notificationName: Notification.Name {
        switch self {
        case .callDidAnswer:
            return Notification.Name("callDidAnswer")
        case .callDidEnd:
            return Notification.Name("callDidEnd")
        case .callDidFail:
            return Notification.Name("callDidFail")
        case .callConnecting:
            return Notification.Name("callConnecting")
        case .callRinging:
            return Notification.Name("callRinging")
        case .callConected:
            return Notification.Name("callConected")
        case .registered:
            return Notification.Name("registered")
        case .failedRegistered:
            return Notification.Name("failedRegistered")
        case .receivedCallInBG:
                return Notification.Name("receivedCallInBG")
            case .receivedCallInBGInActve:
                    return Notification.Name("receivedCallInBGInActve")
            
        }
    }
}

public class LinphoneManager {
    
    var iterateTimer: Timer?
    var isCalledEnded: Bool = false
    var call : Optional<OpaquePointer>?
    
    //var receivedCall : Optional<OpaquePointer>?
    
    var account: String = "09611677128"
    var password: String = "rTchY0ubs!p"
    var domain: String = "202.4.97.11"
    var stopTimer: Bool = false {
        
        didSet {
            print("Start")
        }
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
           // NSLog("Ringing")
            //self.delegate.callRinging()
            NotificationCenter.default.post(name:  CallStateNotificationName.registered.notificationName, object: nil)
            
        case LinphoneRegistrationCleared:
            NSLog("End")
            // NotificationCenter.default.post(name: CallStateNotificationName.failedRegistered.notificationName, object: nil)
            
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
            
         
            //appdelegate.displayIncomingCall(uuid: UUID(), handle: "displayCaller")
            
            theLinphone.callReceived = call
            
//            if answerCall{
//                ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
//                linphone_core_accept_call(lc, call)
//            }
            
        case LinphoneCallStateStreamsRunning: /**<The media streams are established and running*/
            NSLog("callStateChanged: LinphoneCallStreamsRunning")
             NotificationCenter.default.post(name:  CallStateNotificationName.callDidAnswer.notificationName, object: nil)
            
        case is LinphoneCallDir: /**<The call encountered an error*/
            NSLog("callStateChanged: LinphoneCallError")
       
        
         
//            LinphoneCallIncomingReceived,
//            LinphoneCallOutgoingInit,
//            LinphoneCallOutgoingProgress,
        case  LinphoneCallStateOutgoingRinging :
             NSLog("LinphoneCallOutgoingRinging")
             NotificationCenter.default.post(name: CallStateNotificationName.callRinging.notificationName, object: nil)
            
        case  LinphoneCallStateOutgoingProgress :
             NSLog("LinphoneCallOutgoingProgress")
             NotificationCenter.default.post(name:  CallStateNotificationName.callConnecting.notificationName, object: nil)
        case LinphoneCallStateEnd:
                 NotificationCenter.default.post(name: CallStateNotificationName.callDidEnd.notificationName, object: nil)
            
        case LinphoneCallStateReleased:
            NSLog("LinphoneCallStateReleased")
             NotificationCenter.default.post(name: CallStateNotificationName.callDidEnd.notificationName, object: nil)
            if let callReceived = theLinphone.callReceived {
                linphone_core_terminate_call(theLinphone.lc,callReceived);
                //linphone_call_unref(callReceived);
                theLinphone.callReceived = nil
            }

        /*
            LinphoneCallIdle
            Initial call state
            
            LinphoneCallIncomingReceived
            This is a new incoming call
            
            LinphoneCallOutgoingInit
            An outgoing call is started
            
            LinphoneCallOutgoingProgress
            An outgoing call is in progress
            
            LinphoneCallOutgoingRinging
            An outgoing call is ringing at remote end
            
            LinphoneCallOutgoingEarlyMedia
            An outgoing call is proposed early media
            
            LinphoneCallConnected
            Connected, the call is answered
            
            LinphoneCallStreamsRunning
            The media streams are established and running
            
            LinphoneCallPausing
            The call is pausing at the initiative of local end
            
            LinphoneCallPaused
            The call is paused, remote end has accepted the pause
            
            LinphoneCallResuming
            The call is being resumed by local end
            
            LinphoneCallRefered
            The call is being transfered to another party, resulting in a new outgoing call to follow immediately
            
            LinphoneCallError
            The call encountered an error
            
            LinphoneCallEnd
            The call ended normally
            
            LinphoneCallPausedByRemote
            The call is paused by remote end
            
            LinphoneCallUpdatedByRemote
            The call's parameters change is requested by remote end, used for example when video is added by remote
            
            LinphoneCallIncomingEarlyMedia
            We are proposing early media to an incoming call
            
            LinphoneCallUpdated
            The remote accepted the call update initiated by us
            
            LinphoneCallReleased
            The call object is no more retained by the core
            */
        default:
            NSLog("Default call state")
        }
    }
    
    init() {
        
        theLinphone.lct = LinphoneCoreVTable()
        isCalledEnded = false
        
        // Enable debug log to stdout
        linphone_core_set_log_file(nil)
        linphone_core_set_log_level(BctbxLogLevel(rawValue: BctbxLogLevel.RawValue(CTL_DEBUG)))
        
        // Load config
        let configFilename = documentFile("linphonerc")
        let factoryConfigFilename = bundleFile("linphonerc-factory")
        
        let configFilenamePtr: UnsafePointer<Int8> = configFilename.cString(using: String.Encoding.utf8.rawValue)!
        let factoryConfigFilenamePtr: UnsafePointer<Int8> = factoryConfigFilename.cString(using: String.Encoding.utf8.rawValue)!
        let lpConfig = linphone_config_new_with_factory(configFilenamePtr, factoryConfigFilenamePtr)

        // Set Callback
        theLinphone.lct?.registration_state_changed = registrationStateChanged
        theLinphone.lct?.call_state_changed = callStateChanged
        
        if theLinphone.lc == nil {
            theLinphone.lc = linphone_core_new_with_config(&theLinphone.lct!, lpConfig, nil)
           // theLinphone.lc = lc
        }
        // Set ring asset
        let ringbackPath = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/ringback.wav").absoluteString
        linphone_core_set_ringback(theLinphone.lc, ringbackPath)

        let localRing = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Sounds/\(UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone)  ?? "Sounds/toy-mono.wav")").absoluteString
        linphone_core_set_ring(theLinphone.lc, localRing) 
        
    }
    
    fileprivate func bundleFile(_ file: NSString) -> NSString{
        return Bundle.main.path(forResource: file.deletingPathExtension, ofType: file.pathExtension)! as NSString
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    
    //
    // This is the start point to know how linphone library works.
    //
    func demo() {
       makeCall()
//        autoPickImcomingCall()
        idle()
    }
    func startReceivingCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
    }
    
    func makePhoneCall(calleeAccount: String) -> Optional<OpaquePointer>? {
       // let calleeAccount = "+8801710441906"
        
//        guard let _ = setIdentify() else {
//            print("no identity")
//            return;
//        }
        stopTimer = false
        
        call = linphone_core_invite(theLinphone.lc, calleeAccount)
        //iterateTimer?.invalidate()
        //setTimer()
       // idle()
        return call
    }
    
    func isInConference() -> Bool {
        return linphone_core_is_in_conference(theLinphone.lc) == 0 ? false : true
    }
    
    func makeConference() {
        linphone_core_add_all_to_conference(theLinphone.lc)
    }
    
    func pauseCall(call: OpaquePointer) {
        linphone_call_pause(call)
    }
    
    func resumeCall(call: OpaquePointer) {
        linphone_call_resume(call)
    }
    
    func enableMic() {
        linphone_core_enable_mic(theLinphone.lc, 1);
    }
    
    func disableMic() {
        linphone_core_enable_mic(theLinphone.lc, 0);
    }
    
    func endCall() {
        linphone_core_terminate_all_calls(theLinphone.lc)
        idle()
//        if let call = call {
//            //linphone_core_terminate_call(theLinphone.lc,call);
//            //linphone_call_unref(call);
//
//        }
    }
    
    func makeConferencePhoneCall(calleeAccounts: [String]) {
        // let calleeAccount = "+8801710441906"
        
        guard let _ = setIdentify() else {
            print("no identity")
            return;
        }
        for calleeAccount in calleeAccounts {
            let call = linphone_core_invite(theLinphone.lc, calleeAccount.replacingOccurrences(of: " ", with: ""))
            Thread.sleep(until: Date().addingTimeInterval(1))
            linphone_core_add_to_conference(theLinphone.lc,call)
        }
        //local_conference_mode
        
        setTimer()
        idle()
    }
    
    func makeCall(){
        let calleeAccount = "+8801710441906"
        
        guard let _ = setIdentify() else {
            print("no identity")
            return;
        }
        //theLinphone.
        //LinphoneCo
        linphone_core_invite(theLinphone.lc, calleeAccount)
        setTimer()
//        shutdown()
    }
    
    func receiveCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
//        shutdown()
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
        linphone_core_add_auth_info(theLinphone.lc, info); /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, domain); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(theLinphone.lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(theLinphone.lc, proxy_cfg); /*set to default proxy*/
        
        
        return proxy_cfg!
    }
    
    func setIdentify() -> OpaquePointer? {
        
        // Reference: http://www.linphone.org/docs/liblinphone/group__registration__tutorials.html
        
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
        
        linphone_core_set_user_agent(theLinphone.lc,"(iOS)","")
        
        let info=linphone_auth_info_new(linphone_address_get_username(from), nil, password, nil, nil, nil); /*create authentication structure from identity*/
        linphone_core_add_auth_info(theLinphone.lc, info); /*add authentication info to LinphoneCore*/
        
        // configure proxy entries
        linphone_proxy_config_set_identity(proxy_cfg, identity); /*set identity with user name and domain*/
        let server_addr = String(cString: linphone_address_get_domain(from)); /*extract domain address from identity*/
        
        linphone_address_destroy(from); /*release resource*/
        
        linphone_proxy_config_set_server_addr(proxy_cfg, domain); /* we assume domain = proxy server address*/
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
        linphone_core_add_proxy_config(theLinphone.lc, proxy_cfg); /*add proxy config to linphone core*/
        linphone_core_set_default_proxy_config(theLinphone.lc, proxy_cfg); /*set to default proxy*/
        
        
        return proxy_cfg!
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_set_conference_factory_uri(proxy_cfg, "sip:conference-factory@sip.linphone.org");
        linphone_proxy_config_enable_register(proxy_cfg, 10); /* activate registration for this proxy config*/
    }
    
    func shutdown(){
        
        NSLog("Shutdown..")
        
        isCalledEnded = true
        iterateTimer?.invalidate()
        iterateTimer = nil
        
        let proxy_cfg = linphone_core_get_default_proxy_config(theLinphone.lc); /* get default proxy config*/
        linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
        linphone_proxy_config_enable_register(proxy_cfg, 0); /*de-activate registration for this proxy config*/
        linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/

        while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared) {
            linphone_core_iterate(theLinphone.lc); /*to make sure we receive call backs before shutting down*/
            ms_usleep(50000);
        }
        
        linphone_core_destroy(theLinphone.lc);
    }
    
    @objc func iterate(){
        if let lc = theLinphone.lc {
            if !isCalledEnded {
            linphone_core_iterate(lc); /* first iterate initiates registration */
            }
        }
    }
    
    func setTimer(){
        iterateTimer = Timer.scheduledTimer(
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
