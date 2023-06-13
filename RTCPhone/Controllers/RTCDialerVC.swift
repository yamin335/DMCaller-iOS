//
//  RTCDialerVC.swift
//  RTCPhone
//
//  Created by Admin on 21/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import AVFoundation
import INTULocationManager
import AudioToolbox

enum FromVC {
    case UserContactsListVC
    case DialerVC
    case NoneToShow
}

enum IncomingCallState : String {
    case pushReceived = "pushreceived"
    case connecting = "connecting"
    case connected = "connected"
    case ringing = "ringing"
    case accepting = "accepting"
    case accepted = "accepted"
    case speaking = "speaking"
    case end = "end"
    case missed = "missed"
    case received = "received"
    
}

enum RTCCallState : String {
    case incoming = "incoming"
    case outgouning = "outgouning"
    case ringing = "ringing"
    case accepting = "accepting"
    case connecting = "connecting"
    case connected = "connected"
    case speaking = "speaking"
    case end = "end"
    case missed = "missed"
    case received = "received"
}

enum CallDialType : String {
    case contact = "contact"
    case dial = "dial"
    case received = "received"
}



class RTCDialerVC: UIViewController {

    @IBOutlet weak var callButton: UIButton! {
        didSet {
            callButton.layer.masksToBounds = true
            callButton.layer.cornerRadius = callButton.frame.size.width/2
        }
    }
    @IBOutlet weak var volumeBtn: UIButton! {
        didSet {
            volumeBtn.layer.masksToBounds = true
            volumeBtn.layer.cornerRadius = volumeBtn.frame.size.width/2
        }
    }
    @IBOutlet weak var muteBtn: UIButton! {
        didSet {
            muteBtn.layer.masksToBounds = true
            muteBtn.layer.cornerRadius = muteBtn.frame.size.width/2
        }
    }
    @IBOutlet weak var btnPauseCall: UIButton! {
        didSet {
            btnPauseCall.layer.masksToBounds = true
            btnPauseCall.layer.cornerRadius = btnPauseCall.frame.size.width/2
        }
    }
    @IBOutlet weak var btnDialPad: UIButton! {
        didSet {
            btnDialPad.layer.masksToBounds = true
            btnDialPad.layer.cornerRadius = btnDialPad.frame.size.width/2
        }
    }
    @IBOutlet weak var btnAddCall: UIButton! {
        didSet {
            btnAddCall.layer.masksToBounds = true
            btnAddCall.layer.cornerRadius = btnAddCall.frame.size.width/2
        }
    }
    @IBOutlet weak var btnConferenceCallList: UIButton! {
        didSet {
            btnConferenceCallList.layer.masksToBounds = true
            btnConferenceCallList.layer.cornerRadius = btnConferenceCallList.frame.size.width/2
        }
    }
    
    @IBOutlet weak var labelSpeaker: UILabel!
    @IBOutlet weak var labelHold: UILabel!
    @IBOutlet weak var labelMute: UILabel!
    //    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var KeyPadContainer: UIView!
    @IBOutlet weak var secondaryControlButtonsView: UIView!
    @IBOutlet weak var HideBtnOutlet: UIButton!
//    @IBOutlet weak var KeyPadBtnOutlet: UIButton!
    @IBOutlet weak var CallDialNumber: UITextField!
    @IBOutlet var KeyViewOutlet: [UIView]!
    @IBOutlet var KeyOutlet: [UILabel]!
//    @IBOutlet weak var KeyPlusOutlet: UILabel!
//    @IBOutlet weak var CallBtnBottomConstraintsOutlet: NSLayoutConstraint!
//    @IBOutlet weak var CallDialNumberHeightOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var conferenceCallTableView: UITableView!
    @IBOutlet weak var conferenceCallListView: UIView!
    @IBOutlet weak var zeroAndPlusButtonView: UIView! {
        didSet {
            zeroAndPlusButtonView.layer.masksToBounds = true
            zeroAndPlusButtonView.layer.cornerRadius = zeroAndPlusButtonView.frame.size.width/2
        }
    }
    
    @IBAction func KeyPadBtnAction(_ sender: UIButton) {
        secondaryControlButtonsView.isHidden = true
        KeyPadContainer.isHidden = false
        isKeyboardVisible = true
        CallDialNumber.isHidden = false
        HideBtnOutlet.isHidden = false
        hideTopView()
//        CallBtnBottomConstraintsOutlet.constant = 16
        
    }
    
    @IBAction func HideBtnAction(_ sender: UIButton) {
        secondaryControlButtonsView.isHidden = false
        KeyPadContainer.isHidden = true
        isKeyboardVisible = false
        CallDialNumber.isHidden = true
        HideBtnOutlet.isHidden = true
        CallDialNumber.text = ""
        showTopView()
//        CallBtnBottomConstraintsOutlet.constant = 160
    }
    
    @IBAction func AddCallButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mainTabbarVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController") as? MainTabbarController, let manager = linphoneManager else {
            return
        }
        mainTabbarVC.modalPresentationStyle = .pageSheet
        mainTabbarVC.conferenceAdded = {
            if AppGlobalValues.conferenceNumber.isNotEmpty {
                self.lastCall = manager.makePhoneCall(calleeAccount: AppGlobalValues.conferenceNumber)
                self.isConferenceCall = true
            }
        }
        self.present(mainTabbarVC, animated: true, completion: nil)
    }
    
    
    @IBAction func hideConferenceCallList(_ sender: Any) {
        conferenceCallListView.isHidden = true
    }
    
    @IBAction func showConferenceCallList(_ sender: Any) {
        conferenceCallListView.isHidden = false
    }
    
    private func hideTopView() {
        userAvatarImageView.isHidden = true
        contactName.isHidden = true
        contactPhoneNumber.isHidden = true
        statusLabel.isHidden = true
    }
    
    private func showTopView() {
        userAvatarImageView.isHidden = false
        contactName.isHidden = false
        contactPhoneNumber.isHidden = false
        statusLabel.isHidden = false
    }
    
    var startDateTime: Date?
    var endDateTime: Date?
    var timerStartTime: Date?
    var callType: RTCCallState = .connecting
    var duration: Double = 0
    
    var isConferenceCall: Bool = false
    var isFromUserContacts: Bool = false
    var profileImage: UIImage?
    var callDialType: CallDialType = .contact
    var isAMissedCall: Bool = false
    var isCallLogSaved: Bool = false
    var lastCall : Optional<OpaquePointer>?
    
    var isKeyboardVisible = false
    
    var currentCalls: [String : ConferenceCall] = [:]
    var currentCallNumbers: [String] = []
    
    @IBOutlet weak var userAvatarImageView: UIImageView! {
        didSet {
            userAvatarImageView.layer.borderWidth = 1
            userAvatarImageView.layer.masksToBounds = false
            userAvatarImageView.layer.cornerRadius = userAvatarImageView.bounds.height/2
            userAvatarImageView.clipsToBounds = true
        }
    }
    
    
    var nameOfUser: String?
    var phoneNumberOfuser: String?
    var image: UIImage!
    var linphoneManager: LinphoneManager?
    var conferenceCallManager: ConferenceCallManager?
    var callReceivedManager: CallReceivedManager?
    
    var isVolumeSelected: Bool = false
    var ismuteBtnSelected: Bool = false
    var isPauseSelected: Bool = false
    var isFromMainVCApear: Bool = false
    
    var bgInactiveRcevdCall: Bool = false
    var bgInactiveAnsCall: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        bgInactiveRcevdCall = false
        bgInactiveAnsCall = false
if let inactiveanscall = UserDefaults.standard.value(forKey: "isauto") as? Bool, inactiveanscall {

        }
        
        self.conferenceCallManager = ConferenceCallManager()
        
        AppGlobalValues.isCallOngoing = true
        
        conferenceCallTableView.reloadData()
        
        loadContactsFromDatabase()
        
        self.statusLabel.text = "Connecting..."
//        self.view.backgroundColor = UIColor(hex: 0x990026)
//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
//        backgroundImage.image = UIImage(named: "Last display 1242 x 2208")
//        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
//        self.view.insertSubview(backgroundImage, at: 0)
        
        CallDialNumber.backgroundColor = UIColor.clear
        CallDialNumber.text = ""
        CallDialNumber.adjustsFontSizeToFitWidth = true
//        KeyPlusOutlet.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
//        CallBtnBottomConstraintsOutlet.constant = 160
        if UIScreen.main.bounds.size.width == 320{
//            CallDialNumberHeightOutlet.constant = 30
//            CallDialNumber.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.thin)
        }
        
        // Do any additional setup after loading the view.
        for Key in KeyOutlet {
            //Key.layer.borderColor = UIColor.darkGray.cgColor
            Key.font = UIScreen.main.bounds.size.width == 320 ? UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.thin) : UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.thin)
            Key.layer.masksToBounds = true
            Key.layer.cornerRadius = Key.frame.size.width/2
            //Key.backgroundColor = UIColor.lightGray
            //Key.layer.borderWidth = 2.0;
            //Key.layer.cornerRadius = 8.0
        }
        
        for KeyView in KeyViewOutlet {
            //let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            let tapGuestureLong = UILongPressGestureRecognizer(target: self, action: #selector(tapActionLong(_:)))
            //KeyView.addGestureRecognizer(tapGuesture)
            if KeyView.tag == 11 {
                KeyView.addGestureRecognizer(tapGuestureLong)
            }
            KeyView.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        let isNowInBD = UserDefaults.standard.bool(forKey: AppConstants.keyIsLocatedInBD)
        let currentLocation = UserDefaults.standard.string(forKey: AppConstants.keyCurrentLocation) ?? ""
        
        if isNowInBD && currentLocation.isNotEmpty && currentLocation.contains(",") {
            let locationValues = currentLocation.components(separatedBy: ",")
            guard locationValues.count == 2, let _ = Double(locationValues[0]), let _ = Double(locationValues[1]) else {
                verifyLocationAndCallDial()
                return
            }
            self.callDial()
        } else {
            verifyLocationAndCallDial()
        }
//        SwiftLocation.Locator.requestAuthorizationIfNeeded()
//        SwiftLocation.Locator.currentPosition(accuracy: .country).onSuccess { location in
//            print("Location found: \(location)")
//            }.onFailure { err, last in
//                print("Failed to get location: \(err)")
//        }
        /*
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocation(withDesiredAccuracy: .city,
                                        timeout: 10.0,
                                        delayUntilAuthorized: true) { (currentLocation, achievedAccuracy, status) in
                                            if (status == INTULocationStatus.success) {
                                                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                // currentLocation contains the device's current location
                                                
                                                // Add below code to get address for touch coordinates.
                                                let geoCoder = CLGeocoder()
                                                if let latitude = currentLocation?.coordinate
                                                    .latitude, let longitude = currentLocation?.coordinate.longitude {
                                                
                                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                                geoCoder.reverseGeocodeLocation(location, completionHandler:
                                                    {
                                                        placemarks, error -> Void in
                                                        
                                                        // Place details
                                                        guard let placeMark = placemarks?.first else { return }
                                                        
                                                       
                                                        // Country
                                                        if let countryCode = placeMark.isoCountryCode, countryCode == "BD" {
                                                            //print(country)
                                                            self.callDial()
                                                        } else {
                                                            let alert = UIAlertController(title: "Error", message: "You are outside of Bangladesh", preferredStyle: UIAlertController.Style.alert)
                                                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                                                                self.dismiss(animated: true, completion: nil)
                                                            }))
                                                        
                                                            self.present(alert, animated: true, completion: nil)
                                                        }
                                                })
                                                }
                                                
                                                if let description =  currentLocation?.description,  description.lowercased().contains("bangladesh") {
                                                    
                                                } else {
                                                    
                                                }
                                            }
                                            else if (status == INTULocationStatus.timedOut) {
                                                // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                // However, currentLocation contains the best location available (if any) as of right now,
                                                // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                            }
                                            else {
                                                let alert = UIAlertController(title: "Error", message: "Please enable location service", preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                                                    self.dismiss(animated: true, completion: nil)
                                                    }))
                                                self.present(alert, animated: true, completion: nil)
                                            }
        }
        */
        
    }
    
    func verifyLocationAndCallDial() {
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
                    self.callDial()
                } else {
                    return
                }
            }
        } else {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
//    @objc func tapAction(_ sender: UITapGestureRecognizer) {
//
//        var valueOfPressedButton : String = "\(sender.view!.tag)"
//
//        switch valueOfPressedButton {
//        case "10":
//            valueOfPressedButton = "*"
//        case "11":
//            valueOfPressedButton = "0"
//        case "12":
//            valueOfPressedButton = "#"
//        default: break
//        }
//
//        if #available(iOS 9.0, *) {
//            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1105), nil)
//        } else {
//            AudioServicesPlaySystemSound(1105)
//        }
//        //print("\(valueOfPressedButton)")
//        CallDialNumber.insertText("\(valueOfPressedButton)")
//
//        if let digit = valueOfPressedButton.utf8.first?.byteSwapped{
//            CallManager.sendDTMF(digit: Int8(digit))
//        }
//    }
    
    func KeyViewActionWith(tag: Int) {
        
        var valueOfPressedButton : String = "\(tag)"
        
        switch valueOfPressedButton {
        case "10":
            valueOfPressedButton = "*"
        case "11":
            valueOfPressedButton = "0"
        case "12":
            valueOfPressedButton = "#"
        default: break
        }
        
        if #available(iOS 9.0, *) {
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1105), nil)
        } else {
            AudioServicesPlaySystemSound(1105)
        }
        //print("\(valueOfPressedButton)")
        CallDialNumber.insertText("\(valueOfPressedButton)")
        
        if let digit = valueOfPressedButton.utf8.first?.byteSwapped{
            CallManager.sendDTMF(digit: Int8(digit))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isKeyboardVisible {
            return
        }
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            // do something with your currentPoint
            //print("Game over!")
            for obstacleView in KeyViewOutlet {
                // Convert the location of the obstacle view to this view controller's view coordinate system
                
              
                    let obstacleViewFrame = self.view.convert(obstacleView.frame, from: obstacleView.superview)
                    
                    // Check if the touch is inside the obstacle view
                    if obstacleViewFrame.contains(currentPoint) {
                        obstacleView.addRippleEffect(viewMargin: 20)
                        self.KeyViewActionWith(tag: obstacleView.tag)
//                        obstacleView.showAnimation {
//                            self.KeyViewActionWith(tag: obstacleView.tag)
//                        }
                    }
               
            }
            
            
        }
    }
    
    @objc func tapActionLong(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began && isKeyboardVisible) {
            //print("Long")
            //print(sender.view!.tag)
            
            var valueOfPressedButton : String = "\(sender.view!.tag)"
            
            switch valueOfPressedButton {
            case "11":
                valueOfPressedButton = "+"
            default: break
            }
            
            if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1105), nil)
            } else {
                AudioServicesPlaySystemSound(1105)
            }
            //print("\(valueOfPressedButton)")
            CallDialNumber.insertText("\(valueOfPressedButton)")
            
            if let digit = valueOfPressedButton.utf8.first?.byteSwapped{
                CallManager.sendDTMF(digit: Int8(digit))
            }
        }
        
    }
    
    func callDial() {
        if isFromUserContacts {
            if let img = self.profileImage {
                self.userAvatarImageView.image = img
                contactName.text = nameOfUser ?? phoneNumberOfuser
            } else {
                print("Nil value")
                if let nameOfUser = nameOfUser, !nameOfUser.isEmpty {
                    contactName.text = nameOfUser
                    self.userAvatarImageView.setImageForName(string: nameOfUser, circular: true, textAttributes: nil)
                } else {
                    contactName.text = phoneNumberOfuser
                }
            }
        } else {
            setCallerDisplayName()
//            if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll() {
//                if contacts.count >  0 {
//                    for contact in contacts {
//                        if let phoneNumbers = contact.phonenumbers, let num = phoneNumberOfuser?.suffix(11), phoneNumbers.contains(num) {
//                            nameOfUser = contact.familyName
//                        }
////                        for phoneNumber in contact.phonenumbers?.enumerated() {
////
////                        }
//                    }
//                }
//            }
//            
//            if let num = phoneNumberOfuser?.suffix(11), let contactFromDB:[PhoneNumbers] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "number = '\(num)'")) {
//                if contactFromDB.count > 0 {
//                    let firstName = contactFromDB[0].contact?.givenName ?? ""
//                    let lastName = contactFromDB[0].contact?.familyName ?? ""
//                    let fullName = firstName + " " + lastName
//                    nameOfUser = fullName.trim()
//                }
//            }
            
            if let nameOfUser = nameOfUser, !nameOfUser.isEmpty {
                contactName.text = nameOfUser
                userAvatarImageView.setImageForName(string: nameOfUser, circular: true, textAttributes: nil)
            } else if let num = phoneNumberOfuser {
                contactName.text = num
                userAvatarImageView.setImageForName(string: num, circular: true, textAttributes: nil)
            }
        }
        
        
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        
        contactPhoneNumber.text = "\(self.phoneNumberOfuser!)"
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.callConnecting(_:)),
                                       name: CallStateNotificationName.callConnecting.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.callRinging(_:)),
                                       name: CallStateNotificationName.callRinging.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.callDidAnswer(_:)),
                                       name: CallStateNotificationName.callDidAnswer.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.callDidEnd(_:)),
                                       name: CallStateNotificationName.callDidEnd.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.callDidEnd(_:)),
                                       name: CallStateNotificationName.callDidFail.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.receivedCallInBG(_:)),
                                       name: CallStateNotificationName.receivedCallInBG.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(RTCDialerVC.receivedCallInBGInActve(_:)),
                                       name: CallStateNotificationName.receivedCallInBGInActve.notificationName,
                                       object: nil)
        
        
        
        if callDialType == .received {
            setCallerDisplayName()
//            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
//                for contact in appdelegate.orderedContacts {
//                    for contactS in contact.value {
//                        let contactObject = Contact(contact: contactS)
//                        for numberEntry in contactObject.phoneNumbers {
//                            let trimmedContactNumber = numberEntry.phoneNumber.replacingOccurrences(of: " ", with: "").trim().suffix(11)
//                            let trimmedUserNumber = self.phoneNumberOfuser!.replacingOccurrences(of: " ", with: "").trim().suffix(11)
//                            if  trimmedContactNumber.contains(trimmedUserNumber) {
//                                self.nameOfUser = contactObject.displayName
//                                if let name = self.nameOfUser, !name.isEmpty {
//                                    contactName.text = name
//                                }
//                                break
//
//                            }
//                        }
////                        if  let _ = contactObject.phoneNumbers.first(where: {$0.phoneNumber.replacingOccurrences(of: " ", with: "").trim().contains(self.phoneNumberOfuser!) }) {
////                            self.nameOfUser = contactObject.displayName
////                            if let name = self.nameOfUser, !name.isEmpty {
////                                contactName.text = name
////                            }
////                            break
////                        }
//                    }
//                }
//            }
            
            startDateTime = Date()
            NotificationCenter.default.post(name: CallStateNotificationName.callRinging.notificationName, object: nil)
//            callButton.setBackgroundImage(UIImage(named: "call"), for: .normal)
            //callButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.5254901961, blue: 0.2980392157, alpha: 1)
            //callButton.addTarget(self, action: #selector(acceptCall(_:)), for: .touchUpInside)
            callButton.addTarget(self, action: #selector(callhangUpBtnAction(_:)), for: .touchUpInside)

            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("appdelegate is missing")
                return
            }
            
            callReceivedManager = appdelegate.theLinphoneManager
            //appdelegate.displayIncomingCall(uuid: UUID(), handle: phoneNumberOfuser ?? "Name")
            //callReceivedManager?.receivedCallAccepted = { isAccept in
                DispatchQueue.main.async {
                    self.isAMissedCall = false
                    self.callType = .speaking
                    //self.startTimer()
                }
           // }
            
            isCallLogSaved = false
            
            
            
        } else {
            
             callButton.addTarget(self, action: #selector(callhangUpBtnAction(_:)), for: .touchUpInside)
            
//            if currentCallList.count > 1 {
//                isConferenceCall = true
//                self.conferenceCallManager = ConferenceCallManager()
//                //self.conferenceCallManager?.makeConferencePhoneCall(calleeAccounts: currentCallList.keys)
//            } else if currentCallList.count == 1 {
//                self.linphoneManager = LinphoneManager()
//                self.linphoneManager?.makePhoneCall(calleeAccount: currentCallList.first?.key ?? "")
//            } else
            if let phoneNumberOfuser = phoneNumberOfuser {
                //let callManager = CallManager()
                //callManager.startCall(handle: phoneNumberOfuser, videoEnabled: false)
//                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
//
//                    print("appdelegate is missing")
//                    return
//                }
//                // Speaker Box Call START
//                appdelegate.callManager.startCall(handle: phoneNumberOfuser)
                self.linphoneManager = LinphoneManager()
                self.lastCall = self.linphoneManager?.makePhoneCall(calleeAccount: phoneNumberOfuser)
                var newCallPhoneNumber = phoneNumberOfuser
                var newCallContactName = self.nameOfUser ?? ""
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate, newCallContactName.isEmpty {
                    let trimmedUserNumber = phoneNumberOfuser.replacingOccurrences(of: " ", with: "").trim().suffix(11)
                    newCallPhoneNumber = String(trimmedUserNumber)
                    if let localContactName = appdelegate.contactsDict[String(trimmedUserNumber)], !localContactName.isEmpty {
                        newCallContactName = localContactName
                    } else {
                        newCallContactName = newCallPhoneNumber
                    }
                }
                let conferenceCall = ConferenceCall(name: newCallContactName, mobile: newCallPhoneNumber, call: self.lastCall)
                self.currentCalls[newCallPhoneNumber] = conferenceCall
                self.currentCallNumbers.append(newCallPhoneNumber)
                //
                //            self.conferenceCallManager = ConferenceCallManager()
                //            self.conferenceCallManager?.makeConferencePhoneCall(calleeAccounts:["+8801869753281","+8801844080123"])
            }
            
//            NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChange), name: NSNotification.Name.AVAudioSession.routeChangeNotification, object: nil)
        }
        
    }
    
    func loadContactsFromDatabase() {
        DispatchQueue.main.async {
            let sortDescriptor = NSSortDescriptor(key: "givenName", ascending: true)
            
            var contacts : [Contacts] = []
            contacts = (MRCoreData.defaultStore?.selectAll(sortDescriptors: [sortDescriptor]))!
                
            var contactsDict = [String : String]()
                
            for contact in contacts {
                if let phoneNumbers = contact.phonenumbers?.allObjects as? [PhoneNumbers] {
                    for phoneNumber in phoneNumbers {
                        if let number = phoneNumber.number {
                            let trimmedNumber = number.replacingOccurrences(of: " ", with: "").trim().suffix(11)
                            contactsDict[String(trimmedNumber)] = "\(contact.givenName!) \(contact.familyName!)".trim()
                        }
                    }
                }
            }
            
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.contactsDict = contactsDict
               // print("Local Contacts: \(contactsDict)")
            }
        }

    }
    
    func setCallerDisplayName() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            let trimmedUserNumber = self.phoneNumberOfuser!.replacingOccurrences(of: " ", with: "").trim().suffix(11)
            if let localContactName = appdelegate.contactsDict[String(trimmedUserNumber)], !localContactName.isEmpty {
                self.nameOfUser = localContactName
            } else {
                self.nameOfUser = String(trimmedUserNumber)
            }
            self.contactName.text = self.nameOfUser
        }
    }
    
    
    @objc func receivedCallInBGInActve(_ sender: NSNotification) {
        bgInactiveAnsCall = true
        
        if let _ = theLinphone.callReceived {
            receivedCallAnswer()
        }
        
        if bgInactiveRcevdCall {
            receivedCallAnswer()
        }
    }
    
    @objc func receivedCallInBG(_ sender: NSNotification) {
        if !isFromMainVCApear {
            receivedCallAnswer()
        } else if bgInactiveAnsCall {
            receivedCallAnswer()
        } else {
            bgInactiveRcevdCall = true
        }
    }
    
    func receivedCallAnswer() {
        if callDialType == .received {
                 
           
          
            
            startDateTime = Date()
            NotificationCenter.default.post(name: CallStateNotificationName.callRinging.notificationName, object: nil)
//            callButton.setBackgroundImage(UIImage(named: "call"), for: .normal)
            //callButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.5254901961, blue: 0.2980392157, alpha: 1)
            //callButton.addTarget(self, action: #selector(acceptCallClick(_:)), for: .touchUpInside)
            callButton.addTarget(self, action: #selector(callhangUpBtnAction(_:)), for: .touchUpInside)

            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("appdelegate is missing")
                return
            }
            
            callReceivedManager = appdelegate.theLinphoneManager
            self.acceptCall()
            isCallLogSaved = false
            
            
            
        }
    }
    
    func acceptCall() {
        callReceivedManager?.acceptCall()
        //UserDefaults.standard.set(true, forKey: "isCallAlreadyReceived")
//        callButton.setBackgroundImage(UIImage(named: "call"), for: .normal)
        //callButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.5254901961, blue: 0.2980392157, alpha: 1)
        callButton.addTarget(self, action: #selector(callhangUpBtnAction(_:)), for: .touchUpInside)
        
        callType = .speaking
        isCallLogSaved = false
        DispatchQueue.main.async {
            self.startTimer()
        }
        
    }
    
    @objc func audioSessionRouteChange() {
        DispatchQueue.main.async {
           // self.switchDeviceSpeakerButton.isSelected = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType == AVAudioSessionPortBuiltInSpeaker
        }
    }
    
//    @objc func acceptCall(_ sender: UIButton) {
//
//
//        callReceivedManager?.acceptCall()
////        callButton.setBackgroundImage(UIImage(named: "call"), for: .normal)
//        //callButton.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.5254901961, blue: 0.2980392157, alpha: 1)
//        callButton.addTarget(self, action: #selector(callhangUpBtnAction(_:)), for: .touchUpInside)
//
//        callType = .speaking
//        isCallLogSaved = false
//        DispatchQueue.main.async {
//            self.startTimer()
//        }
//    }
    
    @objc func callConnecting(_ sender: NSNotification) {
        // connecting
        self.isAMissedCall = true
        callType = .connecting
        startDateTime = Date()
        DispatchQueue.main.async {
            self.isAMissedCall = true
            if !self.isConferenceCall {
                self.statusLabel.text = "Connecting..."
            }
        }
    }
    
    @objc func callRinging(_ sender: NSNotification) {
        // callRinging
        configureAudioSession()
        self.isAMissedCall = true
        callType = .ringing
        DispatchQueue.main.async {
            if !self.isConferenceCall {
                if self.callDialType == .received {
                    self.statusLabel.text = "Connecting..."
                } else{
                    self.statusLabel.text = "Ringing..."
                }
            }
//            if let prevCall =  self.prevCall {
//                linphone_call_resume(prevCall)
//            }
//
//            if !self.isConferenceCall {
//
//                if let call = sender.object as? Optional<OpaquePointer> {
//                    linphone_call_pause(call);
//                    self.prevCall = call
//                }
//                self.isConferenceCall  = true
//            }
        }
        
    }
    
//    func makeConference(<#parameters#>) {
//        if !self.isConferenceCall {
//            guard let manager = self.linphoneManager else {
//                return
//            }
//            //manager.pauseCall(call: prvCall!)
//            manager.makeConference()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.second) {
//                if manager.isInConference() {
//                    self.btnConferenceCallList.isEnabled = true
//                    self.isConferenceCall  = true
//                    //manager.resumeCall(call: prvCall!)
//                }
//            }
//        }
//    }
    
    @objc func callDidAnswer(_ sender: NSNotification) {
        self.isAMissedCall = false
        callType = .speaking
        
        if !isConferenceCall {
            self.startTimer()
        }
        
        if AppGlobalValues.conferenceNumber.isEmpty {
            return
        }
        
        if self.isConferenceCall {
            guard let manager = self.linphoneManager else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.second) {
                manager.makeConference()
                if manager.isInConference() {
                    self.btnConferenceCallList.isEnabled = true
                    let newCallPhoneNumber = AppGlobalValues.conferenceNumber
                    var newCallContactName = AppGlobalValues.conferenceName
                    if let appdelegate = UIApplication.shared.delegate as? AppDelegate, newCallContactName.isEmpty {
                        let trimmedUserNumber = newCallPhoneNumber.replacingOccurrences(of: " ", with: "").trim().suffix(11)
                        if let localContactName = appdelegate.contactsDict[String(trimmedUserNumber)], !localContactName.isEmpty {
                            newCallContactName = localContactName
                        } else {
                            newCallContactName = String(trimmedUserNumber)
                        }
                    }
                    let conferenceCall = ConferenceCall(name: newCallContactName, mobile: newCallPhoneNumber, call: self.lastCall)
                    self.currentCalls[newCallPhoneNumber] = conferenceCall
                    self.currentCallNumbers.append(newCallPhoneNumber)
                    AppGlobalValues.conferenceNumber = ""
                    AppGlobalValues.conferenceName = ""
                    self.conferenceCallTableView.reloadData()
                }
            }
        }
        
        //startDateTime = Date()
//        DispatchQueue.main.async {
//
//            self.statusLabel.text = "Speaking"
//
//            if let prvCall = self.prevCall {
//                //linphone_call_resume(prevCall)
//                //linphone_core_add_all_to_conference(theLinphone.lc)
//                // make conference call
//                if !self.isConferenceCall {
//                    guard let manager = self.linphoneManager else {
//                        return
//                    }
//                    //manager.pauseCall(call: prvCall!)
//                    manager.makeConference()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.second) {
//                        if manager.isInConference() {
//                            self.btnConferenceCallList.isEnabled = true
//                            self.isConferenceCall  = true
//                            self.conferenceCallTableView.reloadData()
//                            //manager.resumeCall(call: prvCall!)
//                        }
//                    }
//                }
//            }
//
//
//
//            if !self.isConferenceCall {
//                self.startTimer()
//                if self.callDialType == .dial {
//                    self.startTimer()
//                }
//                if let call = sender.object as? Optional<OpaquePointer> {
//                    //linphone_call_pause(call);
//                    self.prevCall = call
//                }
//
//            self.conferenceCallManager = ConferenceCallManager()
//            self.conferenceCallManager?.makeConferencePhoneCall(calleeAccounts:["+8801869753281"])
//            }
//        }
    }
    
    @objc func callDidEnd(_ sender: NSNotification) {
        //UserDefaults.standard.set(false, forKey: "isCallAlreadyReceived")
        
//        if currentCallNumbers.count > 1 {
//            currentCallNumbers.removeFirst()
//            return
//        }
        
        
        UserDefaults.standard.set("", forKey: "callerID")
        if !isCallLogSaved {
            
        endDateTime = Date()

        switch callType {
        case .connecting:
            let newCallLog = CallLog(context: MRDBManager.savingContext)
            newCallLog.duration = self.duration
            //guard let time = self.timerStartTime else {return}
                if let startDateTime = startDateTime {
                    newCallLog.startDateTime = startDateTime
                }
            newCallLog.callDialType = callDialType.rawValue
            newCallLog.phoneNumber = self.phoneNumberOfuser ?? ""
            newCallLog.phoneUser = self.nameOfUser ?? ""
            newCallLog.callType = RTCCallState.outgouning.rawValue
             newCallLog.hourMS = self.temp
            try? MRDBManager.savingContext.save()
            isCallLogSaved = true
        case .ringing:
            let newCallLog = CallLog(context: MRDBManager.savingContext)
            newCallLog.duration = self.duration
            //guard let time = self.timerStartTime else {return}
                if let startDateTime = startDateTime {
                    newCallLog.startDateTime = startDateTime
                }
            newCallLog.callDialType = callDialType.rawValue
            newCallLog.phoneNumber = self.phoneNumberOfuser ?? ""
            newCallLog.phoneUser = self.nameOfUser ?? ""
            
            if callDialType == .received {
                newCallLog.callType = RTCCallState.missed.rawValue
            } else {
                newCallLog.callType = RTCCallState.outgouning.rawValue
            }
             newCallLog.hourMS = self.temp
             try? MRDBManager.savingContext.save()
            isCallLogSaved = true
        case .speaking:
            let newCallLog = CallLog(context: MRDBManager.savingContext)
            newCallLog.duration = self.duration
            //guard let time = self.timerStartTime else {return}
                if let startDateTime = startDateTime {
                    newCallLog.startDateTime = startDateTime
                }
            newCallLog.callDialType = callDialType.rawValue
            newCallLog.phoneNumber = self.phoneNumberOfuser ?? ""
            newCallLog.phoneUser = self.nameOfUser ?? ""
            if callDialType == .received {
               newCallLog.callType = RTCCallState.incoming.rawValue
            } else {
              newCallLog.callType = RTCCallState.outgouning.rawValue
            }
            newCallLog.hourMS = self.temp
             try? MRDBManager.savingContext.save()
             isCallLogSaved = true
        default:
            break

        }
        }
         if callDialType == .received {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                
                print("appdelegate is missing")
                return
            }
            
            
            if let callID = appdelegate.providerDelegate?.callID {
                appdelegate.providerDelegate?.provider.reportCall(with: callID, endedAt: nil, reason: .answeredElsewhere)
            }
            appdelegate.providerDelegate?.isCallReceivedFromBacground = false
            appdelegate.providerDelegate?.incomingCall = nil
        
         } else {
           endCall() // call Speaker Box Call END
        }
        ////////////////////////////////////////
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func endCall() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }
        
        /*
         End any ongoing calls if the provider resets, and remove them from the app's list of calls,
         since they are no longer valid.
         */
       // for call in appdelegate.callManager.calls {
            appdelegate.callManager.endCall()
        //}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    
        super.viewDidDisappear(animated)
       
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = false
        AppGlobalValues.isCallOngoing = false
        UserDefaults.standard.set(false, forKey: "inactivepush") // Call already finished
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callhangUpBtnAction(_ sender: UIButton) {
        print("Dissmissed")
        if callDialType == .received {
           CallManager.endReceivedCall()
        } else {
        linphoneManager?.endCall()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func volumeControlBtnAction(_ sender: UIButton) {
        if isVolumeSelected {
            self.volumeBtn.tintColor = .black
            self.labelSpeaker.text = "Speaker"
            //volumeBtn.setImage(UIImage(named: "volume"), for: .normal)
            let audioSession = AVAudioSession.sharedInstance()

            do {
                // try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try audioSession.setActive(true, options: [])
                
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
        } else {
                //sender.setImage(UIImage(named: "volume_selected"), for: .normal)
            self.volumeBtn.tintColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
            self.labelSpeaker.text = "Headset"
            let audioSession = AVAudioSession.sharedInstance()

            do {
         //try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .videoChat, options: .defaultToSpeaker)
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                try audioSession.setActive(true, options: [])
              
                
            } catch let error as NSError {
                print("audioSession error: \(error.localizedDescription)")
            }
      
        }
        isVolumeSelected = !isVolumeSelected
    }
    
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let audioSession = AVAudioSession.sharedInstance()
       // try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)

       
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [])
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try? audioSession.setPreferredIOBufferDuration(0.005)
            
             try audioSession.setPreferredSampleRate(8000.0)
             try audioSession.setActive(true, options: [])
        }
        catch( let error) {
            print(error)
        }
    }
    
    @IBAction func muteBtnAction(_ sender: UIButton) {
        guard let manager = self.linphoneManager else {
            return
        }
        
        if ismuteBtnSelected {
            manager.enableMic()
            self.muteBtn.tintColor = .black
            self.labelMute.text = "Mute"
        } else {
            manager.disableMic()
            self.muteBtn.tintColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
            self.labelMute.text = "Un-mute"
        }
        ismuteBtnSelected = !ismuteBtnSelected
        
//        if ismuteBtnSelected {
//            sender.tintColor = .black
//            if #available(iOS 13.0, *) {
//                sender.setImage(UIImage(systemName: "mic.slash"), for: .normal)
//                sender.tintColor = .label
//            } else {
//                // Fallback on earlier versions
//                muteBtn.setImage(UIImage(named: "mute-gray"), for: .normal)
//            }
//
//            //Dialer sound
//            let audioSession = AVAudioSession.sharedInstance()
//            do { try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//                try audioSession.setMode(AVAudioSessionModeVoiceChat)
//                try audioSession.setPreferredSampleRate(44100)
//                try audioSession.setPreferredIOBufferDuration(0.005)
//            }
//            catch { print(error)
//                //            Logger.logData("Failed to init audio session")
//            }
//            linphone_core_enable_mic(theLinphone.lc, 1);
//            let audioSession = AVAudioSession.sharedInstance()
//            do {
//                try audioSession.setActive(true)
//
//            } catch _ {
//            }
//        } else {
//            linphone_core_enable_mic(theLinphone.lc, 0);
//            sender.tintColor = .blue
//            if #available(iOS 13.0, *) {
//                sender.setImage(UIImage(systemName: "mic"), for: .normal)
//                sender.tintColor = .blue
//            } else {
//                // Fallback on earlier versions
//                muteBtn.setImage(UIImage(named: "mute_selected"), for: .normal)
//            }
//
//            let audioSession = AVAudioSession.sharedInstance()
//            do {
//                try audioSession.setActive(false)
//            } catch _ {
//            }
//        }
//        ismuteBtnSelected = !ismuteBtnSelected
    }
    
    @IBAction func pauseControlBtnAction(_ sender: UIButton) {
        guard let manager = self.linphoneManager else {
            return
        }
        isPauseSelected = !isPauseSelected
        if isPauseSelected {
            for call in currentCalls {
                manager.pauseCall(call: call.value.call!!)
            }
            self.btnPauseCall.tintColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
            self.labelHold.text = "Resume Call"
        } else {
            for call in currentCalls {
                manager.resumeCall(call: call.value.call!!)
            }
            self.btnPauseCall.tintColor = .black
            self.labelHold.text = "Hold"
        }
        
//        if isPauseSelected {
//            for call in currentCalls {
//                manager.pauseCall(call: call.value.call!!)
//            }
//            sender.tintColor = .blue
////            if #available(iOS 13.0, *) {
////                sender.setImage(UIImage(systemName: "pause"), for: .normal)
////                sender.tintColor = .label
////            } else {
////                // Fallback on earlier versions
////                sender.setImage(UIImage(named: "pause_selected"), for: .normal)
////            }
//        } else {
//            for call in currentCalls {
//                manager.resumeCall(call: call.value.call!!)
//            }
//            sender.tintColor = .black
////            if #available(iOS 13.0, *) {
////                sender.setImage(UIImage(systemName: "pause"), for: .normal)
////                sender.tintColor = .blue
////            } else {
////                // Fallback on earlier versions
////                sender.setImage(UIImage(named: "pause"), for: .normal)
////            }
//        }
    }

    var temp: String = ""
    
    func startTimer() {
        self.btnAddCall.isEnabled = true
        timerStartTime = Date()
        Timer.every(1.second) {
            DispatchQueue.main.async {
                let timeNow = Date()
                if let startTime = self.timerStartTime {
                    let timediffSeconds =  timeNow.timeIntervalSince(startTime)
                    self.duration = timediffSeconds
                    let secondsToHoursMinutesSeconds = self.secondsToHoursMinutesSeconds(seconds: Int(abs(timediffSeconds)))
                    self.statusLabel.text =  self.timeText(from: secondsToHoursMinutesSeconds.h)+":"+self.timeText(from: secondsToHoursMinutesSeconds.m)+":"+self.timeText(from: secondsToHoursMinutesSeconds.s)
                    
                    self.temp = self.timeText(from: secondsToHoursMinutesSeconds.h)+":"+self.timeText(from: secondsToHoursMinutesSeconds.m)+":"+self.timeText(from: secondsToHoursMinutesSeconds.s)
                }
            }
        }
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (h:Int, m:Int, s:Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func timeText(from number: Int) -> String {
        return number < 10 ? "0\(number)" : "\(number)"
    }

}

extension RTCDialerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCallNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConferenceCallViewCell", for: indexPath) as! ConferenceCallViewCell
        let phoneNumber = currentCallNumbers[indexPath.row]
        let call = currentCalls[phoneNumber]
        cell.call = call
        if let contactName = call?.name, contactName.isNotEmpty {
            cell.contactNameLabel.text = contactName
        } else {
            cell.contactNameLabel.text = phoneNumber
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
