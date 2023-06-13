//
//  CallDialerViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts

class CallDialerViewController: UIViewController {

    @IBOutlet weak var phonePadStackView: UIStackView!
    @IBOutlet weak var padContainerView: UIView!
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    
    /// Contacts ordered in dictionary alphabetically using `sortOrder`.
    private var orderedContacts = [String: [CNContact]]()
    private var sortedContactKeys = [String]()
    
    public private(set) var selectedContacts = [Contact]()
    private var filteredContacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let dialView: BMDialView = BMDialView()
        dialView.setupDialPad(frame: CGRect.init(x: 0, y: 0, width: self.padContainerView.frame.size.width, height: self.padContainerView.frame.size.height))
        //print(self.padContainerView.frame.size.width)
        //print(self.padContainerView.frame.size.height)
        self.padContainerView.addSubview(dialView)
        
        dialView.callTapped = { [weak self] phoneNumber in
            if phoneNumber != ""{
                self?.showCallVC(phoneNumber: phoneNumber)
            }
            
//                        if let completion = self.completion {
//                            completion(false)
//                            self.dismiss(animated: true, completion: nil)
//                        }
        }
        dialView.translatesAutoresizingMaskIntoConstraints = false
//        dialView.anchor(nil, left: self.padContainerView.leftAnchor, bottom: self.padContainerView.bottomAnchor, right: self.padContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.padContainerView.frame.size.width, heightConstant: 300)
//        padContainerView = PasswordContainerView.create(in: phonePadStackView, digit: 15)
//        padContainerView.delegate = self
//        
//        padContainerView.isAddBeneficiary = false
//        padContainerView.exitClicked = { [weak self] phoneNumber in
//            
//            self?.showCallVC(phoneNumber: phoneNumber)
//          
//            
////            if let completion = self.completion {
////                completion(false)
////                self.dismiss(animated: true, completion: nil)
////            }
//        }

        // Do any additional setup after loading the view.
        
        if let navUtil = AppManager.dialNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        
        reloadContacts()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CallDialerViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func showCallVC(phoneNumber: String) {
        if AppGlobalValues.isCallOngoing {
            if let parentMain = self.parent?.parent, parentMain.isKind(of: MainTabbarController.self) {
                AppGlobalValues.conferenceNumber = phoneNumber
                parentMain.dismiss(animated: true, completion: nil)
            }
        } else {
            if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                callVC.phoneNumberOfuser = phoneNumber
                callVC.callDialType = .dial
                callVC.modalPresentationStyle = .fullScreen
                self.present(callVC, animated: true, completion: nil)
            }
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
    
    public var sortOrder: CNContactSortOrder = CNContactSortOrder.userDefault

    private func firstLetter(for contact: CNContact) -> String? {
        var firstCharacter: Character? = nil
        
        switch sortOrder {
            
        case .userDefault where CNContactsUserDefaults.shared().sortOrder == .familyName:
            fallthrough
            
        case .familyName:
            fallthrough
            
        case .userDefault where CNContactsUserDefaults.shared().sortOrder == .givenName:
            fallthrough
            
        case .givenName:
            fallthrough
            
        default:
            firstCharacter = contact.givenName.first
        }
        
        guard let letter = firstCharacter else { return nil }
        let firstLetter = String(letter)
        return firstLetter.containsAlphabets() ? firstLetter : nil
    }
    open weak var contactDelegate: ContactsPickerDelegate?
    
    private func getContacts(_ completion:  @escaping ContactsHandler) {
        // TODO: Set up error domain
        let error = NSError(domain: "JFContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {  action in
                //self.contactDelegate?.contactPicker(self, didContactFetchFailed: error)
                completion([], error)
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
                        completion([], error! as NSError?)
                    })
                }
                else{
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            var contactsArray = [CNContact]()
            
            var orderedContacts = [String : [CNContact]]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                try contactsStore.enumerateContacts(with: contactFetchRequest, usingBlock: { [weak self] (contact, stop) -> Void in
                    
                    //Adds the `contact` to the `contactsArray` if the closure returns true.
                    //If the closure doesn't exist, then the contact is added.
//                    if let shouldIncludeContactClosure = self?.shouldIncludeContact, !shouldIncludeContactClosure(contact) {
//                        return
//                    }
                    
                    contactsArray.append(contact)
                    
                    //contactsArray.sort{ ($0["name"] as! String) < ($1["name"] as! String) }
                    
                    //                    //Ordering contacts based on alphabets in firstname
                    
                    
                })
                
                
                
                let sortedContactsArray = contactsArray.sorted(by: { lhs,rhs in
                    return lhs.givenName < rhs.givenName
                    
                })
                
                for contact in sortedContactsArray {
                    
                    var key: String = "A"
                    //
                    //                    //If ordering has to be happening via family name change it here.
                    if let firstLetter = self.firstLetter(for: contact) {
                        key = firstLetter.uppercased()
                    }
                    //
                    var contactsForKey = orderedContacts[key] ?? [CNContact]()
                    contactsForKey.append(contact)
                    orderedContacts[key] = contactsForKey
                }
                
               // self.orderedContacts = orderedContacts
//                DispatchQueue.main.async {  
//                if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
//                    appdelegate.orderedContacts = orderedContacts
//                }
//                }
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    //self.sortedContactKeys.append("#")
                }
                completion(sortedContactsArray, nil)
                
            } catch let error as NSError {
                /// Catching exception as enumerateContactsWithFetchRequest can throw errors
                print(error.localizedDescription)
            }
            
        }
    }
    
    open func reloadContacts() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.getContacts { [weak self] (contacts, error) in
                if (error == nil) {
                   
                }
            }
        }
    }


    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func listShowBtnAction(_ sender: UIButton) {
        //performSegue(withIdentifier: "gotoCalledListVC", sender: self)
        
        if let contactsDetailsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCUserContactsDetailsVC") as? RTCUserContactsDetailsVC {
            contactsDetailsVC.name = ""
            contactsDetailsVC.phoneNumbers = []
            contactsDetailsVC.isFromDialVC = true
            self.navigationController?.show(contactsDetailsVC, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoCalledListVC" {
            let des = segue.destination as? CallDialerListVC
        }
    }
}

extension CallDialerViewController: PasswordInputCompleteProtocol {
    
    
    func didEnterInput(_ passwordContainerView: PasswordContainerView, input: String) {
        if !input.isEmpty {
            //sequenceStatusLabel.text = ""
        }
    }
    
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
//        if validation(input) {
//            validationSuccess()
//        } else {
//            validationFail()
//        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
    }
}
