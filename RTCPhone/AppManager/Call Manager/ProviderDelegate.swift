/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	CallKit provider delegate class, which conforms to CXProviderDelegate protocol
*/

import Foundation
import UIKit
import CallKit
import AVFoundation


final class ProviderDelegate: NSObject, CXProviderDelegate {

    let callManager: SpeakerboxCallManager
    var theLinphoneManager: CallReceivedManager
    let provider: CXProvider
    let callController = CXCallController()
    var callID: UUID = UUID()
    var isCallReceivedFromBacground: Bool = false
    var timer: Timer? = nil
    var timerCount = 0
    let MAXRINGINGTIME = 25
    var isCallEndByTimer: Bool = false

    init(callManager: SpeakerboxCallManager,theLinphoneManager: CallReceivedManager) {
        self.theLinphoneManager = theLinphoneManager
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)

        super.init()

        provider.setDelegate(self, queue: nil)
    }

    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("Kotha Dialer", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        providerConfiguration.supportsVideo = false

        providerConfiguration.maximumCallsPerCallGroup = 1

        providerConfiguration.supportedHandleTypes = [.phoneNumber]

        providerConfiguration.iconTemplateImageData = #imageLiteral(resourceName: "img_incoming").pngData()
        
        let ringtone = UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone)
//        if let directory = UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtoneDirectory) {
//            if directory.isNotEmpty {
//                ringtone = "\(directory)/\(ringtone)"
//            }
//        }

        providerConfiguration.ringtoneSound = ringtone
        
        return providerConfiguration
    }
    
    func endCall() {
        let endCallAction = CXEndCallAction(call: callID)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        
        requestTransaction(transaction, action: "endCall")
    }
    
    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction \(action) successfully")
            }
        }
    }

    // MARK: Incoming Calls

     var incomingCall: SpeakerboxCall?
    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        
       callID = uuid
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo

        // pre-heat the AVAudioSession
        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: callID, update: update) { error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = SpeakerboxCall(uuid: uuid)
                call.handle = handle
                self.incomingCall = call
                self.callManager.addCall(call)
              
            } else {
                self.endCall()
            }
            
            self.timer = Timer.every(1.second) {
                self.timerCount += 1
                if self.timerCount == self.MAXRINGINGTIME {
                    self.timerCount = 0
                    self.endCall()
                    self.timer?.invalidate()
                    self.timer = nil
                    self.isCallEndByTimer = true
//                    guard let call = self.incomingCall, let trimmedNumber = call.handle?.replacingOccurrences(of: " ", with: "").trim().suffix(11) else {
//
//                        return
//                    }
//
//                    let newCallLog = CallLog(context: MRDBManager.savingContext)
//                    newCallLog.duration = 0
//                    newCallLog.startDateTime = Date()
//                    newCallLog.phoneNumber = String(trimmedNumber)
//                    newCallLog.callType = RTCCallState.missed.rawValue
//                    newCallLog.callDialType = CallDialType.received.rawValue
//                    newCallLog.hourMS = "00:00:00"
//                    try? MRDBManager.savingContext.save()
                }
            }
            
            completion?(error as NSError?)
        }
        
        self.theLinphoneManager.startReceivingCall()
    }

    // MARK: CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        /*
            End any ongoing calls if the provider resets, and remove them from the app's list of calls,
            since they are no longer valid.
         */
    }

    var outgoingCall: SpeakerboxCall?
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        self.timerCount = 0
        self.timer?.invalidate()
        self.timer = nil
        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = SpeakerboxCall(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        //configureAudioSession()
        
        /*
            Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
            to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }

        self.outgoingCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    var answerCall: SpeakerboxCall?
    
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        self.timerCount = 0
        self.timer?.invalidate()
        self.timer = nil
   // Call already answering...
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        if action.callUUID !=  callID {
             action.fail()
        } else {
        guard let call = self.incomingCall else {
            action.fail()
            return
        }
        
        /*
         Configure the audio session, but do not start call audio here, since it must be done once
         the audio session has been activated by the system after having its priority elevated.
         */
        
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
            self.answerCall = call
            
            CallManager.presentReceivedCall(phoneNumber: call.handle ?? "")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: CallStateNotificationName.receivedCallInBGInActve.notificationName, object: nil)
            action.fulfill()
            }
     
       
          
            if(UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .background){
              //  UserDefaults.standard.set(false, forKey: "inactivepush")
//                DispatchQueue.main.async {
//                    UserDefaults.standard.set(false, forKey: "inactivepush")
//                    UserDefaults.standard.synchronize()
//                }
               
            } else if(UIApplication.shared.applicationState == .inactive) {
//                UserDefaults.standard.set(true, forKey: "isauto")
//                UserDefaults.standard.synchronize()
        

                //DispatchQueue.main.async {
               // CallManager.presentReceivedCall(phoneNumber: call.handle ?? "")
               // }
//                UserDefaults.standard.set(true, forKey: "inactivepush")
//                UserDefaults.standard.synchronize()
                       //  let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC
                          //  callVC?.phoneNumberOfuser = "234234234"
                           // callVC?.callDialType = .received
                   
                   
                  // vc.callingState = .ANSWERED
                  // vc.callDirection = .ANSWERED
                   
               // callVC?.modalPresentationStyle = .fullScreen
                
               // UIApplication.shared.delegate?.window??.parentVC?.present(callVC!, animated: true, completion: nil)
                
            }
            
        // Signal to the system that the action has been successfully performed.
     
            
//            UserDefaults.standard.set(true, forKey: "pushcall")
//
//            UserDefaults.standard.synchronize()
            //if isCallReceivedFromBacground == false {
           
           
            //}
        //CallManager.presentReceivedCall(phoneNumber: call.handle ?? "")
        }
    }

    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        UserDefaults.standard.set("", forKey: "callerID")
        UserDefaults.standard.set(false, forKey: "inactivepush") // Call already cancelled
        UserDefaults.standard.synchronize()
        self.timerCount = 0
        self.timer?.invalidate()
        self.timer = nil
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
//        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
//            action.fail()
//
//            return
//        }
        
        if action.callUUID !=  callID {
            action.fail()
        } else {
            guard let call = self.incomingCall, let trimmedNumber = call.handle?.replacingOccurrences(of: " ", with: "").trim().suffix(11) else {
                action.fail()
                return
            }
            
            let newCallLog = CallLog(context: MRDBManager.savingContext)
            newCallLog.duration = 0
            newCallLog.startDateTime = Date()
            newCallLog.phoneNumber = String(trimmedNumber)
            
            // Afer implement normal push to end call need to fix here
            if self.isCallEndByTimer {
                newCallLog.callType = RTCCallState.missed.rawValue
            } else {
                newCallLog.callType = RTCCallState.incoming.rawValue
            }
            
            self.isCallEndByTimer = false
            
            newCallLog.callDialType = CallDialType.received.rawValue
            newCallLog.hourMS = "00:00:00"
            try? MRDBManager.savingContext.save()
        //action.fulfill()
        
        // Trigger the call to be ended via the underlying network service.
        //call.endCall()

        // Signal to the system that the action has been successfully performed.
        
        //CallManager.endReceivedCall()
        action.fulfill()

        // Remove the ended call from the app's list of calls.
        //callManager.removeCall(call)
        
        //CallManager.presentReceivedCall(phoneNumber: call.handle ?? "")
        }
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold

        // Stop or start audio in response to holding or unholding the call.
        call.isMuted = call.isOnHold

        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")

        // React to the action timeout if necessary, such as showing an error UI.
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
//        outgoingCall?.startCall(withAudioSession: audioSession) { success in
//            if success {
//                self.callManager.addCall(self.outgoingCall!)
//                self.outgoingCall?.startAudio()
//            }
//        }
        
        self.answerCall?.answerCall(withAudioSession: audioSession) { success in
            if success {
                self.answerCall?.startAudio()
            }
        }
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")

        /*
             Restart any non-call related audio now that the app's audio session has been
             de-activated after having its priority restored to normal.
         */
       // outgoingCall?.endCall()
        outgoingCall = nil
        //answerCall?.endCall()
        answerCall = nil
        callManager.removeAllCalls()
    }
    
    var session: AVAudioSession?
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try session.setActive(true)
            try session.setMode(AVAudioSession.Mode.voiceChat)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
        } catch {
            print(error)
        }
    }
}
