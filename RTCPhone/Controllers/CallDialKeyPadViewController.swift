//
//  CallDialKeyPadViewController.swift
//  RTCPhone
//
//  Created by Ashraful Islam Masum on 12/22/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import AudioToolbox
import CoreData

class CallDialKeyPadViewController: UIViewController, UITextFieldDelegate, UIActionSheetDelegate, CNContactViewControllerDelegate, CNContactPickerDelegate {
    
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    
    /// Contacts ordered in dictionary alphabetically using `sortOrder`.
    private var orderedContacts = [String: [CNContact]]()
    private var sortedContactKeys = [String]()
    
    public private(set) var selectedContacts = [Contact]()
    private var filteredContacts = [CNContact]()
    private var deleteBtnTimer: Timer?
    
    
    @IBOutlet weak var CallDialNumber: UITextField!
    @IBOutlet weak var DeleteButtonOutlet: UIButton!
    @IBOutlet var KeyViewOutlet: [UIView]!
    @IBOutlet var KeyOutlet: [UILabel]!
    @IBOutlet weak var KeyPlusOutlet: UILabel!
    var addContact : String = "new"
    
    @IBOutlet weak var keypadWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var callButton: UIButton! {
        didSet {
            callButton.layer.masksToBounds = true
            callButton.layer.cornerRadius = callButton.frame.size.width/2
        }
    }
    
    @IBOutlet weak var zeroAndAsteriskKeyView: UIView! {
        didSet {
            zeroAndAsteriskKeyView.layer.masksToBounds = true
            zeroAndAsteriskKeyView.layer.cornerRadius = zeroAndAsteriskKeyView.frame.size.width/2
        }
    }
    //    @IBOutlet weak var keyLabel_1: UILabel! {
//        didSet {
//            keyLabel_1.layer.cornerRadius = keyLabel_1.frame.size.width/2
//        }
//    }
    @IBOutlet weak var addContactBtnOutlet: UIButton!
    @IBAction func addContactBtnAction(_ sender: UIButton) {
        let phoneNumber = self.CallDialNumber.text
        if !phoneNumber!.trimmingCharacters(in: .whitespaces).isEmpty {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "Create New Contact", style: .default) { (action:UIAlertAction) in
                //print("Create New Contact");
                self.addContact = "new"
                let con = CNMutableContact()
                con.phoneNumbers.append(CNLabeledValue(
                    label: "amberPhone", value: CNPhoneNumber(stringValue: phoneNumber!)))
                let npvc = CNContactViewController(forNewContact: con)
                npvc.delegate = self
                
                let navigation = UINavigationController(rootViewController: npvc)
                self.present(navigation, animated: true, completion: nil)
                //self.navigationController?.pushViewController(npvc, animated: true)

            }
            let action2 = UIAlertAction(title: "Add to Existing Contact", style: .default) { (action:UIAlertAction) in
                //print("Add to Existing Contact");
                self.addContact = "update"
                let picker = CNContactPickerViewController()
                picker.delegate = self
                let displayedItems = [CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactBirthdayKey]
                picker.displayedPropertyKeys = displayedItems
            
                self.present(picker, animated: true, completion: nil)
            }
            let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                //print("Cancel");
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Ripple Animation
    
    //MARK: CNContactPickerDelegate methods
    // The selected person and property from the people picker.
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        DispatchQueue.main.async() {
            let con = contact.mutableCopy() as! CNMutableContact
            con.phoneNumbers.append(CNLabeledValue(label: "amberPhone", value: CNPhoneNumber(stringValue: self.CallDialNumber.text!)))
            let npvc = CNContactViewController(forNewContact: con)
            npvc.delegate = self
            npvc.setEditing(true, animated: true)
            npvc.title = "Update Contact"
            
            let navigation = UINavigationController(rootViewController: npvc)
            self.present(navigation, animated: true, completion: nil)
        }
        
        
//        do {
//            let store = CNContactStore()
//            let con = contact.mutableCopy() as! CNMutableContact
//            con.phoneNumbers.append(CNLabeledValue(
//                label: "amberPhone", value: CNPhoneNumber(stringValue: self.CallDialNumber.text!)))
//            let saveRequest = CNSaveRequest()
//            saveRequest.update(con)
//            try store.execute(saveRequest)
//            //print(con.phoneNumbers) // here you are getting identifire
//            var newAddedPhoneNumberIdentifier : String = ""
//            for phoneNumber in con.phoneNumbers {
//                if phoneNumber.value.stringValue == self.CallDialNumber.text!{
//                    newAddedPhoneNumberIdentifier = phoneNumber.identifier
//                }
//            }
//
//            // update to database
//            let identifier = con.identifier
//            if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(identifier)'")), let context = MRCoreData.defaultStore?.defaultSaveContext() {
//                if contacts.count > 0{
//                    //let newContact = contacts[0] as Contacts
//                    let newContact = context.object(with: contacts[0].objectID) as? Contacts
//                    let newPhoneNumber = PhoneNumbers(context: MRDBManager.savingContext)
//                    newPhoneNumber.identifier = newAddedPhoneNumberIdentifier
//                    newPhoneNumber.label = "amberPhone"
//                    newPhoneNumber.number = self.CallDialNumber.text!
//
//                    newContact?.addToPhonenumbers(newPhoneNumber)
//
//                    do {
//                        try context.save()
//
//                        DispatchQueue.main.async() {
//                            let alert = UIAlertController(title: "Success", message: "Contact \(con.givenName) updated successfully", preferredStyle: UIAlertControllerStyle.alert)
//                            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: {_ in
//                                self.CallDialNumber.text = ""
//                            }))
//                            self.present(alert, animated: true, completion: nil)
//                        }
//                    }
//                    catch {
//                        print(error.localizedDescription)
//                    }
//
//                }
//            }
//
//
//        } catch let error{
//            print(error)
//        }
    }
    
    // Implement this if you want to do additional work when the picker is cancelled by the user.
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        picker.dismiss(animated: true, completion: {})
    }
    
    //MARK: CNContactViewControllerDelegate methods
    // Dismisses the new-person view controller.
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if self.addContact == "new" {
            if let contact = contact{
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
                
                DispatchQueue.main.async() {
                    let alert = UIAlertController(title: "Success", message: "Contact \(contact.givenName) added successfully", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: {_ in
                        self.CallDialNumber.text = ""
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        else if self.addContact == "update" {
            if let contact = contact{
                // update to database
                let identifier = contact.identifier
                if let contactFromDB:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(identifier)'")), let context = MRCoreData.defaultStore?.defaultSaveContext() {
                    if contactFromDB.count > 0{
                        let newContact = context.object(with: contactFromDB[0].objectID) as? Contacts
                        newContact?.givenName = contact.givenName
                        newContact?.familyName = contact.familyName
                        
                        
                        // delete old phoneNumbers
                        let context2 = MRCoreData.defaultStore?.defaultDeleteContext()
                        for phoneNumber in contactFromDB[0].phonenumbers?.allObjects as! [PhoneNumbers] {
                            let deletedPhoneNumber = context2?.object(with: phoneNumber.objectID) as? PhoneNumbers
                            newContact?.removeFromPhonenumbers(deletedPhoneNumber!)
                            context2?.delete(deletedPhoneNumber!)
                            do {
                                try context2?.save()
                            }
                            catch{}
                        }
                        
                        // Add new updated phoneNumbers
                        for phoneNumber in contact.phoneNumbers {
                            let newPhoneNumber = PhoneNumbers(context: MRDBManager.savingContext)
                            newPhoneNumber.identifier = phoneNumber.identifier
                            newPhoneNumber.label = phoneNumber.label ?? ""
                            newPhoneNumber.number = phoneNumber.value.stringValue
                            
                            newContact?.addToPhonenumbers(newPhoneNumber)
                        }
                        
                        do {
                            try context.save()
                            
                            DispatchQueue.main.async() {
                                let alert = UIAlertController(title: "Success", message: "Contact \(contact.givenName) updated successfully", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: {_ in
                                    self.CallDialNumber.text = ""
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
                
            }
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    func KeyViewActionWith(tag: Int) {
        //let tag = sender.tag
        var valueOfPressedButton : String?
        
        switch tag {
        case 10:
            valueOfPressedButton = "*"
        case 11:
            valueOfPressedButton = "0"
        case 12:
            valueOfPressedButton = "#"
        default:
            valueOfPressedButton = "\(tag)"
        }

        if #available(iOS 9.0, *) {
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1105), nil)
        } else {
            AudioServicesPlaySystemSound(1105)
        }
        
        CallDialNumber.insertText(valueOfPressedButton!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppGlobalValues.isCallOngoing {
            addContactBtnOutlet.isHidden = true
            keypadWidthConstraint.constant = -40
            self.view.layoutIfNeeded()
        } else {
            keypadWidthConstraint.constant = 0
            addContactBtnOutlet.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)

        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

        CallDialNumber.backgroundColor = UIColor.clear
        CallDialNumber.text = ""
        CallDialNumber.adjustsFontSizeToFitWidth = true
        //CallDialNumber.minimumScaleFactor = 0.7
        //CallDialNumber.lineBreakMode = .byTruncatingHead
        CallDialNumber.delegate = self
        CallDialNumber.inputView = UIView.init(frame: CGRect.zero)
        CallDialNumber.inputAccessoryView = UIView.init(frame: CGRect.zero)
        CallDialNumber.rightViewMode = UITextField.ViewMode.never
        CallDialNumber.textAlignment = NSTextAlignment.center
        CallDialNumber.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        KeyPlusOutlet.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.regular)
        
        for KeyView in KeyViewOutlet {
            //let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            let tapGuestureLong = UILongPressGestureRecognizer(target: self, action: #selector(tapActionLong(_:)))
            //KeyView.addGestureRecognizer(tapGuesture)
            if KeyView.tag == 11 {
                KeyView.addGestureRecognizer(tapGuestureLong)
            }
            KeyView.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        // Do any additional setup after loading the view.
        for Key in KeyOutlet {
//            Key.layer.borderColor = UIColor.darkGray.cgColor
            Key.font = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.regular)
            Key.layer.masksToBounds = true
            Key.layer.cornerRadius = Key.frame.size.width/2
            //Key.backgroundColor = UIColor.lightGray
//            Key.layer.borderWidth = 2.0;
//            Key.layer.cornerRadius = 8.0
        }
        
        zeroAndAsteriskKeyView.layer.masksToBounds = true
        zeroAndAsteriskKeyView.layer.cornerRadius = zeroAndAsteriskKeyView.frame.size.width/2
        
        let tapGuestureDelete = UILongPressGestureRecognizer(target: self, action: #selector(tapActionDelete(_:)))
        DeleteButtonOutlet.addGestureRecognizer(tapGuestureDelete)
        
        // Do any additional setup after loading the view.
        if let navUtil = AppManager.dialNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        reloadContacts()
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CallDialKeyPadViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        //self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tapActionLong(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began) {
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
            
            UIView.animate(withDuration: 0.1,
                animations: {
                    sender.view!.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        sender.view!.transform = CGAffineTransform.identity
                    }
            })
            self.delete()
            CallDialNumber.insertText("\(valueOfPressedButton)")
        }
        
    }

    
    func tappedAnimation(animations: @escaping () -> (), completion: (() -> ())?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: animations) { _ in
            completion?()
        }
    }
    
    @IBAction func CallButton(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.self.transform = CGAffineTransform.identity
                }
        })
        
        let phoneNumber = CallDialNumber.text
        
        if phoneNumber == ""{
            
            let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
            if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callDialType = 'dial' || callDialType = 'contact' || callDialType = 'received' || callType = 'outgouning' || callType = 'incoming' || callType = 'missed'"), sortDescriptors: [sortDescriptor]) {
                if tasks.count > 0{
                    let task = tasks[0]
                    if !task.phoneNumber.isEmpty {
                        CallDialNumber.text = task.phoneNumber
                        CallDialNumber.becomeFirstResponder()
                        return
                    }
                }
                
            }
        }
        
        if phoneNumber != ""{
            self.showCallVC(phoneNumber: phoneNumber!)
        }
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
    
    @IBAction func DeleteButton(_ sender: UIButton) {
        self.delete()
    }
    
    @objc func tapActionDelete(_ sender: UITapGestureRecognizer) {
        if(sender.state == .began){
            deleteBtnTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (t) in
                self.delete()
            })
        }
        else if (sender.state == .ended || sender.state == .cancelled || sender.state == .failed){
            deleteBtnTimer?.invalidate()
        }
    }
    
    func delete() {
        self.CallDialNumber.deleteBackward()
    }
    
    func deleteNumber() {
        var CallDialNumber = self.CallDialNumber.text!
        //self.CallDialNumber.text = String(CallDialNumber!.dropLast())
        if let selectedRange = self.CallDialNumber.selectedTextRange {
            
            let cursorPosition = self.CallDialNumber.offset(from: self.CallDialNumber.beginningOfDocument, to: selectedRange.start)
            print("\(cursorPosition)")
            if cursorPosition > 0 {
                
                // To one position to the left of the current cursor position
                if let selectedRange = self.CallDialNumber.selectedTextRange {
                    // and only if the new position is valid
                    if let newPosition = self.CallDialNumber.position(from: selectedRange.start, offset: -1) {
                        // set the new position
                        self.CallDialNumber.selectedTextRange = self.CallDialNumber.textRange(from: newPosition, to: newPosition)
                    }
                }
                
                let NewCursorPosition = cursorPosition - 1
                CallDialNumber.remove(at: String.Index(encodedOffset: NewCursorPosition))
                self.CallDialNumber.text = CallDialNumber
            }
            //print("\(cursorPosition)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
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
//                    if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
//                        appdelegate.orderedContacts = orderedContacts
//                    }
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


extension CallDialKeyPadViewController: PasswordInputCompleteProtocol {
    
    
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


public extension UIView {
    
    func addRippleEffect(viewMargin: CGFloat) {
        //let path = UIBezierPath(cgPath: UIBezierPath(rect: self.bounds).cgPath)
        let width = self.bounds.size.width - viewMargin
        let height = self.bounds.size.height - viewMargin
        let cornerRadius = height/2
        let path = UIBezierPath(roundedRect: CGRect(x: viewMargin, y: viewMargin, width: width, height: height), cornerRadius: cornerRadius)
        let shapePosition = CGPoint(x: (self.bounds.size.width-viewMargin) / 2.0, y: (self.bounds.size.height-viewMargin) / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = self.bounds
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.gray.cgColor
        rippleShape.strokeColor = UIColor.clear.cgColor
        //rippleShape.lineWidth = max(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        self.layer.addSublayer(rippleShape)
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1))
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.8
        opacityAnim.toValue = nil
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = CFTimeInterval(0.1)
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        rippleShape.add(animation, forKey: "rippleEffect")
    }
    
    func showAnimation(_ completionBlock: @escaping () -> Void) {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}
