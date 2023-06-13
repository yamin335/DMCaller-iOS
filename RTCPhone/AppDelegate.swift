//
//  AppDelegate.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import PushKit
import CallKit
import Contacts
import IQKeyboardManagerSwift
import Firebase
import AVFAudio
import INTULocationManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //https://sendbird.com/developer/tutorials/make-local-calls-with-callkit-and-sendbird-calls
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?
    var theLinphoneManager: CallReceivedManager?
    //var orderedContacts = [String: [CNContact]]()
    var orderedContacts = [String: [Contacts]]()
    let locationManager = CLLocationManager()
    var contactsDict = [String : String]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        AFManager.createAlamofireSession()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.multiRoute, mode: .default)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        theLinphoneManager = CallReceivedManager()
        
        providerDelegate = ProviderDelegate(callManager: callManager, theLinphoneManager: theLinphoneManager!)
        
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
       
        locationManager.delegate = self
        
   
        
//        if let server = UserDefaults.standard.value(forKey: "server") as? String {
//            print(server)
//        } else {
//            UserDefaults.standard.set("119.40.81.8", forKey: "server")
//            UserDefaults.standard.synchronize()
//        }
        
       
        do {
            let _ = try MRCoreData.makeAndGetStore(dataModelName: "RTCPhone")
        } catch let error {
            switch error {
            case MRCoreDataError.creationError(let message):
                print(message)
            default: break
            }
        }
        
        
        //LinphoneManager.startLinphoneCore()
        
        //LinphoneManager.instance.iapManager.notificationCategory = @"expiry_notification";
        // initialize UI
//        self.window?.makeKeyAndVisible()
//        RootViewManager.setup(withPortrait: self.window!.rootViewController as! PhoneMainView)
//        PhoneMainView.instance().startUp()
        //PhoneMainView.instance updateStatusBar:n
        
        
        FirebaseApp.configure()

           // [START set_messaging_delegate]
           Messaging.messaging().delegate = self
           // [END set_messaging_delegate]
           // Register for remote notifications. This shows a permission dialog on first run, to
           // show the dialog at a more appropriate time move this registration accordingly.
           // [START register_for_notifications]
           if #available(iOS 10.0, *) {
             // For iOS 10 display notification (sent via APNS)
             UNUserNotificationCenter.current().delegate = self

             let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
             UNUserNotificationCenter.current().requestAuthorization(
               options: authOptions,
               completionHandler: { _, _ in }
             )
           } else {
             let settings: UIUserNotificationSettings =
               UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
             application.registerUserNotificationSettings(settings)
           }

          // application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().delegate = self
            
            // request permission from user to send notification
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
              if authorized {
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
              }
            })
//         let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC
//            callVC?.phoneNumberOfuser = "234234234"
//            callVC?.callDialType = .received
//
//
//        self.window?.rootViewController = callVC
//        self.window?.makeKeyAndVisible()
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.getLocation { (location) in
                if location.isInBangladesh == false {
                    //UserDefaults.standard.set(false, forKey: AppConstants.keyIsLocatedInBD)
                    return
                } else {
                    UserDefaults.standard.set(true, forKey: AppConstants.keyIsLocatedInBD)
                }
                
                if location.error != nil {
                    //UserDefaults.standard.set("", forKey: AppConstants.keyCurrentLocation)
                    return
                }
                
                if let lat = location.lattitude, let lon = location.longitude {
                    UserDefaults.standard.set("\(lat),\(lon)", forKey: AppConstants.keyCurrentLocation)
                } else {
                    //UserDefaults.standard.set("", forKey: AppConstants.keyCurrentLocation)
                    return
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return true
    }
    
  
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //theLinphoneManager?.shutdown()
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0);
//        bgTask = application.beginBackgroundTask(withName:"MyBackgroundTask", expirationHandler: {() -> Void in
//            print("The task has started")
//            self.theLinphoneManager?.startReceivingCall()
//            application.endBackgroundTask(bgTask)
//            bgTask = UIBackgroundTaskIdentifier.invalid
//        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        if let incomingCall = providerDelegate?.incomingCall {
//            providerDelegate?.isCallReceivedFromBacground = true
//            self.theLinphoneManager?.startReceivingCall()
//            CallManager.presentReceivedCall(phoneNumber: incomingCall.handle ?? "")
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //let  theLinphoneManager = CallReceivedManager()
     
        
      //      providerDelegate?.theLinphoneManager = theLinphoneManager
     //  self.theLinphoneManager?.startReceivingCall()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //self.saveContext()
    }
    
   




func application(_ application: UIApplication,
                  didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
   // If you are receiving a notification message while your app is in the background,
   // this callback will not be fired till the user taps on the notification launching the application.
   // TODO: Handle data of notification
   // With swizzling disabled you must let Messaging know about the message, for Analytics
   // Messaging.messaging().appDidReceiveMessage(userInfo)
   // Print message ID.
   if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
       
       if let uuidString = messageID as? String,
           let handle = messageID as? String,
           let uuid = UUID(uuidString: uuidString) {
           
           // OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
           
           // display incoming call UI when receiving incoming voip notification
           let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
           self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false) { _ in
               UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
           }
       }
   }

   // Print full message.
   print(userInfo)
 }

 // [START receive_message]
 func application(_ application: UIApplication,
                  didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                    -> Void) {
     
   // If you are receiving a notification message while your app is in the background,
   // this callback will not be fired till the user taps on the notification launching the application.
   // TODO: Handle data of notification
   // With swizzling disabled you must let Messaging know about the message, for Analytics
   // Messaging.messaging().appDidReceiveMessage(userInfo)
   // Print message ID.
     
   if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
   

     
     if let uuidString = messageID as? String,
         let handle = messageID as? String,
         let uuid = UUID(uuidString: uuidString) {
         
         // OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
         
         // display incoming call UI when receiving incoming voip notification
         let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
         self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false) { _ in
             UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
         }
     }}
   // Print full message.
   print(userInfo)

   completionHandler(UIBackgroundFetchResult.newData)
 }

 // [END receive_message]
 func application(_ application: UIApplication,
                  didFailToRegisterForRemoteNotificationsWithError error: Error) {
   print("Unable to register for remote notifications: \(error.localizedDescription)")
 }

 // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
 // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
 // the FCM registration token.
 func application(_ application: UIApplication,
                  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     
     let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
    //let deviceToken = credentials.token.reduce("", {$0 + String(format: "%02X", $1) })
//     print("didRegisterForRemoteNotificationsWithDeviceToken token is: \(deviceToken)")
   print("APNs token retrieved: \(deviceToken)")

   // With swizzling disabled you must set the APNs token here.
   // Messaging.messaging().apnsToken = deviceToken
 }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.getLocation { (location) in
                if location.isInBangladesh == false {
                    //UserDefaults.standard.set(false, forKey: AppConstants.keyIsLocatedInBD)
                    return
                } else {
                    UserDefaults.standard.set(true, forKey: AppConstants.keyIsLocatedInBD)
                }
                
                if location.error != nil {
                    //UserDefaults.standard.set("", forKey: AppConstants.keyCurrentLocation)
                    return
                }
                
                if let lat = location.lattitude, let lon = location.longitude {
                    UserDefaults.standard.set("\(lat),\(lon)", forKey: AppConstants.keyCurrentLocation)
                } else {
                    //UserDefaults.standard.set("", forKey: AppConstants.keyCurrentLocation)
                    return
                }
            }
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
 // Receive displayed notifications for iOS 10 devices.
 func userNotificationCenter(_ center: UNUserNotificationCenter,
                             willPresent notification: UNNotification,
                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                               -> Void) {
   let userInfo = notification.request.content.userInfo

   // With swizzling disabled you must let Messaging know about the message, for Analytics
   // Messaging.messaging().appDidReceiveMessage(userInfo)
   // [START_EXCLUDE]
   // Print message ID.
   if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
   }
   // [END_EXCLUDE]
   // Print full message.
   print(userInfo)

   // Change this to your preferred presentation option
   completionHandler([[.alert, .sound]])
 }

 func userNotificationCenter(_ center: UNUserNotificationCenter,
                             didReceive response: UNNotificationResponse,
                             withCompletionHandler completionHandler: @escaping () -> Void) {
   let userInfo = response.notification.request.content.userInfo

   // [START_EXCLUDE]
   // Print message ID.
   if let messageID = userInfo[gcmMessageIDKey] {
     print("Message ID: \(messageID)")
   }
   // [END_EXCLUDE]
   // With swizzling disabled you must let Messaging know about the message, for Analytics
   // Messaging.messaging().appDidReceiveMessage(userInfo)
   // Print full message.
   print(userInfo)
     
     let application = UIApplication.shared
      
      if(application.applicationState == .active){
        print("user tapped the notification bar when the app is in foreground")
//          UserDefaults.standard.set(true, forKey: "pushcall")
//
//          UserDefaults.standard.synchronize()
      }
      
      if(application.applicationState == .inactive) {
//          UserDefaults.standard.set(true, forKey: "pushcall")
//
//          UserDefaults.standard.synchronize()
          
          if AppGlobalValues.isCallOngoing {
              
          } else {
              if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                  callVC.phoneNumberOfuser = "phoneNumber"
                  callVC.callDialType = .received
                  callVC.modalPresentationStyle = .fullScreen
                  self.window?.rootViewController = callVC
              }
          }
        print("user tapped the notification bar when the app is in background")
      }
     

   completionHandler()
 }
}

// [END ios_10_message_handling]
extension AppDelegate: MessagingDelegate {
 // [START refresh_token]
 func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
   print("Firebase registration token: \(String(describing: fcmToken))")
//     guard let username = UserDefaults.standard.string(forKey: "username"), let companyUniqueID = UserDefaults.standard.string(forKey: "companyUniqueID"), let mobile = UserDefaults.standard.string(forKey: "mobileNo"), let deviceToken = fcmToken else {
//         print("Token is not registered")
//         return
//     }
//     let requestBody = FCMTokenRegisterRequest(userid: "rtchubs", apikey: APIConfiguration.apiKEY, mobile_no: mobile, company: "1000", token: deviceToken, imei_number: UUID().uuidString, latitude: 23.565654645, longitude: 97.45345, platform: "ios")
    // self.registerFCMToken(requestBody: requestBody)

   let dataDict: [String: String] = ["token": fcmToken ?? ""]
   NotificationCenter.default.post(
     name: Notification.Name("FCMToken"),
     object: nil,
     userInfo: dataDict
   )
   // TODO: If necessary send token to application server.
   // Note: This callback is fired at each app startup and whenever a new token is generated.
 }

 // [END refresh_token]
}
extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("\(#function) voip token: \(credentials.token)")
        
        let deviceToken = credentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        print("\(#function) token is: \(deviceToken)")
       
        UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
        
        LocationManager.getLocation { (location) in
            if location.isInBangladesh == false {
                return
            }
            guard let username = UserDefaults.standard.string(forKey: "username"),let mobileNo = UserDefaults.standard.string(forKey: "mobileNo") else {
                print("Token is not registered")
                return
            }
            let requestBody = FCMTokenRegisterRequest(userid: AppManager.userID, apikey: APIConfiguration.apiKEY, mobile_no: mobileNo, company: AppManager.companyID, token: deviceToken, imei_number: UUID().uuidString, latitude: 23.565654645, longitude: 97.45345, platform: AppManager.platform)
            self.registerFCMToken(requestBody: requestBody)
            
            if location.error != nil {
                return
            }
            
            if let lattitude = location.lattitude, let longitude = location.longitude {
            
            } else {
                return
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
//        UserDefaults.standard.set("\(payload.dictionaryPayload)", forKey: "last_push")
//        var pushCount = UserDefaults.standard.integer(forKey: "push_count")
//        pushCount += 1
//        UserDefaults.standard.set(pushCount, forKey: "push_count")
//        print("Current Push Count: \(UserDefaults.standard.integer(forKey: "push_count"))")
//
            //UserDefaults.standard.set(false, forKey: "isCallAlreadyReceived")
//            print("\(#function) incoming voip notfication: \(payload.dictionaryPayload)")
//            print("Current push: \(payload.dictionaryPayload)")
            if type == .voIP, let uuidString = payload.dictionaryPayload["uuid"] as? String,
                let callerName = payload.dictionaryPayload["callerName"] as? String,
               let callerID = payload.dictionaryPayload["callerID"] as? String,
                let uuid = UUID(uuidString: uuidString) {
               
                // Stop display same call uuid more than one
//                if let calluuid = UserDefaults.standard.value(forKey: "uuid") as? String, calluuid.lowercased() == uuid.uuidString.lowercased() {
//                    return
//                }
//
//                if let localCallerID = UserDefaults.standard.value(forKey: "callerID") as? String, localCallerID == callerID {
//                    return
//                }
                
                UserDefaults.standard.set(uuidString, forKey: "uuid")
                UserDefaults.standard.set(callerName, forKey: "callerName")
                UserDefaults.standard.set(callerID, forKey: "callerID")
                
                //if(UIApplication.shared.applicationState == .inactive) {
                   UserDefaults.standard.set(true, forKey: "inactivepush")
                   UserDefaults.standard.synchronize()
               // }
                
               
                // OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
               // CallManager.currentIncomingCall = IncomingCallInfo(uuid: uuid.uuidString, callerName: callerName, callerID: callerID,callStatus: .pushReceived)
      
                // display incoming call UI when receiving incoming voip notification
             //   let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                self.displayIncomingCall(uuid: uuid, handle: callerName, hasVideo: false)
            }
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
    
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
    
    func registerFCMToken(requestBody: FCMTokenRegisterRequest) {
        APIServiceManager.fcmTokenRegistration(requestBody: requestBody) { result in
            switch result {
            case .success(let value):
                print("\(value)")

            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
}

