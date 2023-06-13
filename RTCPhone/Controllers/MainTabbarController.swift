//
//  MainTabbarController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts

/*class MainTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
*/

/// Objects that conform to this protocol can become a `delegate` for a `ContactsPicker` instance.
public protocol PhoneContactsPickerDelegate: class {
    
    /// This method is called when the `contactPicker` fails to fetch contacts from the `store`.
    ///
    /// - Parameters:
    ///   - _: The contactPicker whose fetch failed.
    ///   - error: An `NSError` instance that describes the failure.
    func contactPicker(_: MainTabbarController, didContactFetchFailed error: NSError)
    
    /// This method is called when the user presses "Cancel" on the `contactPicker`.
    /// The delegate may choose how to respond to this. You may want to dismiss the picker, or respond in some
    /// other way.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - error: An `NSError` instance describing the cancellation.
    func contactPickerDidCancel(_: MainTabbarController)
    
    /// Called when a contact is selected.
    /// - Note: This method is called when `multiSelectEnabled` is `false`. If `multiSelectEnabled` is `true` then
    /// `contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact])` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contact: The `Contact` that was selected by the user.
    func contactPicker(_: MainTabbarController, didSelectContact contact: Contact)
    
    /// Called when the user finishes selecting multiple contacts.
    /// - Note: This method is called when `multiSelectEnabled` is `true`. If `multiSelectEnabled` is `false` then
    /// `func contactPicker(_: ContactsPicker, didSelectContact contact: Contact)` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contacts: An array of `Contact`'s selected by the user.
    func contactPicker(_: MainTabbarController, didSelectMultipleContacts contacts: [Contact])
}

public extension PhoneContactsPickerDelegate {
    func contactPicker(_: MainTabbarController, didContactFetchFailed error: NSError) { }
    func contactPickerDidCancel(_: MainTabbarController) { }
    func contactPicker(_: MainTabbarController, didSelectContact contact: Contact) { }
    func contactPicker(_: MainTabbarController, didSelectMultipleContacts contacts: [Contact]) { }
}

open class MainTabbarController: UITabBarController, UITabBarControllerDelegate {
    var isDragingStarted:Bool?
    var panView: UIView?
    var onClose: (()->Void)?
    var panGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        return gestureRecognizer
    }()
    var isMenuShow: Bool = false
    var showHideMenu: ((_ isShow: Bool) -> Void)?
    
    var conferenceAdded: (() -> Void)?
    
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    /// The `delegate` for the picker.
    open weak var contactDelegate: PhoneContactsPickerDelegate?
    
    
    //var linphoneManager: CallReceivedManager?
    
    // MARK: View Life Cycle
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if AppGlobalValues.isCallOngoing, let conferenceAdded = conferenceAdded {
            conferenceAdded()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        
        print("Current Push Count: \(UserDefaults.standard.integer(forKey: "push_count"))")
        print("Current Push: \(UserDefaults.standard.string(forKey: "last_push") ?? "No push found")")
        
        AppGlobalValues.appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        delegate = self
        panView = self.view
        panGestureRecognizer.delegate = self
        self.view?.addGestureRecognizer(panGestureRecognizer)
        addTabbarItems()
        
         self.tabBar.unselectedItemTintColor = Theme.tabbarUnSelectedTintColor
        //self.tabBar.barTintColor = UIColor.blue
        
        
//        linphoneManager = CallReceivedManager()
//        linphoneManager?.startReceivingCall()
        selectedIndex  = 2
        
        AppManager.favoritesNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        AppManager.contactsNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        AppManager.callHistoryNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        AppManager.confNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        AppManager.settingsNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        AppManager.dialNavigationBarUtil = NavigationBarUtil(actionDelegate: self)
        
 
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(MainTabbarController.didRegister(_:)),
                                       name: CallStateNotificationName.registered.notificationName,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(MainTabbarController.failedRegister(_:)),
                                       name: CallStateNotificationName.failedRegistered.notificationName,
                                       object: nil)
//        notificationCenter.addObserver(self,
//                                       selector: #selector(MainTabbarController.receivedCallInBG(_:)),
//                                       name: CallStateNotificationName.receivedCallInBG.notificationName,
//                                       object: nil)
        
        if let userID = UserDefaults.standard.value(forKey: "username") as? String, let pass = UserDefaults.standard.value(forKey: "password") as? String {
            if !userID.isEmpty && !pass.isEmpty {
                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                    print("appdelegate is missing")
                    return
                }
                //appdelegate.
                if let proxyConfig = appdelegate.theLinphoneManager?.setIdentify(account: userID, password: pass) {
                    appdelegate.theLinphoneManager?.register(proxyConfig)
                    appdelegate.theLinphoneManager?.setTimer()
                }
            }
        }
   
      
      
        
        // Testing token api
//        LocationManager.getLocation { (location) in
//            if location.isInBangladesh == false {
//                return
//            }
//
//            if location.error != nil {
//                return
//            }
//
//            if let lattitude = location.lattitude, let longitude = location.longitude {
//                guard let userID = UserDefaults.standard.string(forKey: "username"), let companyUniqueID = UserDefaults.standard.string(forKey: "companyUniqueID"), let mobile = UserDefaults.standard.string(forKey: "mobileNo") else {
//                    print("Token is not registered")
//                    return
//                }
//                let requestBody = FCMTokenRegisterRequest(userid: userID, apikey: APIConfiguration.apiKEY, mobile_no: mobile, company: companyUniqueID, token: "deviceToken", imei_number: UUID().uuidString, latitude: lattitude, longitude: longitude, platform: "ios")
//                self.registerFCMToken(requestBody: requestBody)
//            } else {
//                return
//            }
//        }
    }
    
//    func registerFCMToken(requestBody: FCMTokenRegisterRequest) {
//        APIServiceManager.fcmTokenRegistration(requestBody: requestBody) { result in
//            switch result {
//            case .success(let value):
//                print("\(value)")
//
//            case .failure(let error):
//                print("\(error)")
//            }
//        }
//    }
    @objc func receivedCallInBG(_ sender: NSNotification) {
    
    
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //UserDefaults.standard.set("", forKey: "callerID")
//        UserDefaults.standard.set(false, forKey: "isauto")
//        UserDefaults.standard.synchronize()
        loadContactsToDatabase()
        
        if let pushcall = UserDefaults.standard.value(forKey: "inactivepush") as? Bool, pushcall, let callerID = UserDefaults.standard.value(forKey: "callerID") as? String , let uuid = UserDefaults.standard.value(forKey: "uuid") as? String {
          
//            UserDefaults.standard.set(false, forKey: "inactivepush")
//            UserDefaults.standard.synchronize()
            
           // DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: "inactivepush")
                UserDefaults.standard.synchronize()
            CallManager.presentReceivedCall(fromVC:self,phoneNumber:callerID,isFromMainVCApear: true)
            //}
         
       
        }
        
//        if let navUtil = AppManager.navigationBarUtil {
//            navigationItem.titleView = navUtil.addView()
//        }
    }
    
  
    
    @objc func didRegister(_ sender: NSNotification) {
        DispatchQueue.main.async {
            if let navUtil =  AppManager.favoritesNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
            
            if let navUtil =  AppManager.contactsNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
            
            if let navUtil =  AppManager.callHistoryNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
            
            if let navUtil =  AppManager.confNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
            
            if let navUtil =  AppManager.settingsNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
            
            if let navUtil =  AppManager.dialNavigationBarUtil {
                let _  = navUtil.updateOnlineStatus(isOnline: true)
            }
        }
    }
    
    @objc func failedRegister(_ sender: NSNotification) {
        DispatchQueue.main.async {
            if let navUtil = AppManager.favoritesNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
            if let navUtil = AppManager.contactsNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
            if let navUtil = AppManager.callHistoryNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
            if let navUtil = AppManager.confNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
            if let navUtil = AppManager.settingsNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
            if let navUtil = AppManager.dialNavigationBarUtil {
                let _ = navUtil.updateOnlineStatus(isOnline: false)
            }
        }
    }
    
    fileprivate func addTabbarItems() {
        
        tabBar.backgroundImage = UIColor.image(UIColor.white)
//        tabBar.backgroundColor = UIColor.white
        tabBar.tintColor =  Theme.tabbarSelectedTintColor
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.colorFrom(hexString: "#46DAF8", alpha: 0.53)!], for: .selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.red], for: .selected)
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.gray], for: .normal)
        
        let favoriteNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FavoriteViewControllerNav")
        
        let contactsNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContactsViewControllerNav")
        
        let conferenceNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ConferenceViewControllerNav")
        
        let callDialerListNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "callDialerListNav")
        
        let callDialerNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CallDialerViewControllerNav")
        
        let settingsNav = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsViewControllerNav")
        
        callDialerListNav.tabBarItem.image = UIImage(named: "history")
        callDialerListNav.tabBarItem.selectedImage = UIImage(named: "history-select")
        //callDialerListNav.tabBarItem.title = "Call History"
        
        favoriteNav.tabBarItem.image = UIImage(named: "fav_contacts")
        favoriteNav.tabBarItem.selectedImage = UIImage(named: "fav_contacts_select")
        //favoriteNav.tabBarItem.title = GlobalConstants.Strings.favoritesTitle
        
        contactsNav.tabBarItem.image = UIImage(named: "contact")
        contactsNav.tabBarItem.selectedImage = UIImage(named: "contact_select")
        //contactsNav.tabBarItem.title = GlobalConstants.Strings.contactsTitle

        conferenceNav.tabBarItem.image = UIImage(named: "conf")
        conferenceNav.tabBarItem.selectedImage = UIImage(named: "conf_select")
        //conferenceNav.tabBarItem.title = "Conf"
        
        callDialerNav.tabBarItem.image = UIImage(named: "dial")
        callDialerNav.tabBarItem.selectedImage = UIImage(named: "dial_select")
        //callDialerNav.tabBarItem.title = "Dialer"
        
        settingsNav.tabBarItem.image = UIImage(named: "settings")
        settingsNav.tabBarItem.selectedImage = UIImage(named: "settings_select")
        //settingsNav.tabBarItem.title = "Settings"
        
      
        //viewControllers = [contactsNav,callDialerListNav,conferenceNav, callDialerNav,settingsNav]
        //viewControllers = [favoriteNav, contactsNav, callDialerListNav, callDialerNav, conferenceNav, settingsNav]
        
        if AppGlobalValues.isCallOngoing {
            viewControllers = [favoriteNav, contactsNav, callDialerNav, callDialerListNav]
        } else {
            viewControllers = [favoriteNav, contactsNav, callDialerNav, callDialerListNav, settingsNav]
        }
        
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        
    }
    
    private func loadContactsToDatabase() {
        let error = NSError(domain: "JFContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {  action in
                self.contactDelegate?.contactPicker(self, didContactFetchFailed: error)
                //completion([], error)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        //completion([], error! as NSError?)
                    })
                }
                else{
                    self.loadContactsToDatabase()
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            
            DispatchQueue.global().async {
                let contactFetchRequest = CNContactFetchRequest(keysToFetch: self.allowedContactKeys())
                do {
                    try self.contactsStore.enumerateContacts(with: contactFetchRequest,
                                                             usingBlock: { [weak self] (contact, stop) -> Void in
                        if let contactListFromDB: [Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(contact.identifier)'")) {
                            //, let context = MRCoreData.defaultStore?.defaultSaveContext()
                            // Update contact
                            if contactListFromDB.count > 0 {
//                                let newContact = context.object(with: contactListFromDB[0].objectID) as? Contacts
//                                newContact?.givenName = contact.givenName
//                                newContact?.familyName = contact.familyName
//                                
//                                // delete old phoneNumbers
//                                let context2 = MRCoreData.defaultStore?.defaultDeleteContext()
//                                if let phoneNumbers = contactListFromDB[0].phonenumbers?.allObjects as? [PhoneNumbers] {
//                                    for phoneNumber in phoneNumbers {
//                                        let deletedPhoneNumber = context2?.object(with: phoneNumber.objectID) as? PhoneNumbers
//                                        newContact?.removeFromPhonenumbers(deletedPhoneNumber!)
//                                        context2?.delete(deletedPhoneNumber!)
//                                        do {
//                                            try context2?.save()
//                                        } catch{
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//                                }
//                                
//                                // Add new updated phoneNumbers
//                                for phoneNumber in contact.phoneNumbers {
//                                    let newPhoneNumber = PhoneNumbers(context: MRDBManager.savingContext)
//                                    newPhoneNumber.identifier = phoneNumber.identifier
//                                    newPhoneNumber.label = phoneNumber.label ?? ""
//                                    newPhoneNumber.number = phoneNumber.value.stringValue
//                                    
//                                    newContact?.addToPhonenumbers(newPhoneNumber)
//                                }
//
//                                do {
//                                    try context.save()
//                                } catch {
//                                    print(error.localizedDescription)
//                                }
                            } else { // Insert as new contact
                                DispatchQueue.main.async {
                                    let newContact = Contacts(context: MRDBManager.savingContext)
                                    newContact.identifier = contact.identifier
                                    newContact.givenName = contact.givenName
                                    newContact.familyName = contact.familyName
                                    
                                    for phoneNumber in contact.phoneNumbers {
                                        let newPhoneNumber = PhoneNumbers(context: MRDBManager.savingContext)
                                        newPhoneNumber.identifier = phoneNumber.identifier
                                        newPhoneNumber.label = phoneNumber.label ?? ""
                                        newPhoneNumber.number = phoneNumber.value.stringValue
                                        newContact.addToPhonenumbers(newPhoneNumber)
                                    }
                                    try? MRDBManager.savingContext.save()
                                }
                            }
                        }
                    })
                } catch let error as NSError {
                    /// Catching exception as enumerateContactsWithFetchRequest can throw errors
                    print(error.localizedDescription)
                }
                    self.loadContactsFromDatabase()
                }
        }
    }
    
    open func loadContactsFromDatabase() {
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
            }
           // print("Local Contacts: \(contactsDict)")
        }

    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
}

extension MainTabbarController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //        let pageWidth = self.scrollView?.frame.size.width
        //        let page = floor(((self.scrollView?.contentOffset.x)! - pageWidth! / 2) / pageWidth!) + 1;
        //        self.currentPage = Int(page);
        //        visibleCurrentPage()
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print("Offset = %d",scrollView.contentOffset)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("drag")
    }
}
// MARK: - UIGestureRecognizerDelegate
extension MainTabbarController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //        if let scrollView = scrollView, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer , state == .showAll {
        //            let gestureView = gestureRecognizer.view
        //            let point = gestureRecognizer.translation(in: gestureView)
        //            let contentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        //            return contentOffset == 0 && point.y > 0
        //        }
        return true
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MainTabbarController: TopBarActionDelegate {
    func returnToTheCall() {
        self.navigationController?.popViewController(animated: true)
    }
}
