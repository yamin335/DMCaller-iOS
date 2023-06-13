//
//  RTCUserContactsDetailsVC.swift
//  RTCPhone
//
//  Created by Admin on 19/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class RTCUserContactsDetailsVC: UIViewController, CNContactViewControllerDelegate {
    
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var nameView: UIImageView!
    @IBOutlet weak var userCallDialedListView: UITableView!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBAction func favoriteBtnAction(_ sender: UIButton) {
        if let identifier = self.identifier, let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(identifier)'")), let context = MRCoreData.defaultStore?.defaultSaveContext() {
            if contacts.count > 0{
                //let newContact = contacts[0] as Contacts
                let newContact = context.object(with: contacts[0].objectID) as? Contacts
                if newContact!.favorite == 0{
                    newContact!.favorite = 1
                    favoriteBtn.setImage(UIImage(named: "favorite_selected"), for: .normal)
                }
                else if newContact!.favorite == 1{
                    newContact!.favorite = 0
                    favoriteBtn.setImage(UIImage(named: "favorite_not_selected"), for: .normal)
                }
                do {
                    try context.save()
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    @IBAction func updateContact(_ sender: UIBarButtonItem) {
        let store = CNContactStore()
        do{
            let contact : CNContact = try store.unifiedContact(withIdentifier: self.identifier!, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            let con = contact.mutableCopy() as! CNMutableContact
            let npvc = CNContactViewController(forNewContact: con)
            npvc.delegate = self
            npvc.setEditing(true, animated: true)
            npvc.title = "Update Contact"
            
            let navigation = UINavigationController(rootViewController: npvc)
            self.present(navigation, animated: true, completion: nil)
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    //MARK: CNContactViewControllerDelegate methods
    // Dismisses the new-person view controller.
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
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
                                let contactUpdated : Contact = Contact(contact: newContact!)
                                self.name = contactUpdated.displayName
                                self.usersNameLabel.text = self.name
                                self.nameView.setImageForName(string: self.name!, circular: true, textAttributes: nil)
                                self.phoneNumbers = contactUpdated.phoneNumbers
                                self.userCallDialedListView.reloadData()
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    var isFromDialVC: Bool = false
    var name: String?
    var identifier: String?
    var favorite: Int16?
    var phoneNumbers: [(phoneNumber: String, phoneLabel: String)]?
    var avatarImage: UIImage?
    var tasks: [CallLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "User Details"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

        
        if let nam = name, !isFromDialVC {
            self.usersNameLabel.text = nam
            self.nameView.setImageForName(string: nam, circular: true, textAttributes: nil)
        }
        
//        if isFromDialVC {
//            topProfileViewCont.constant = 30
//        }
        
        if favorite == 1{
            favoriteBtn.setImage(UIImage(named: "favorite_selected"), for: .normal)
        }
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("_____________________ _______________________ __________________________ _________________________ printing Code view will apperar")

        DispatchQueue.main.async {
            self.userCallDialedListView.reloadData()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func loadData() {
        //MARK: Edited at 27/06/2018 for updating tableview descending order
        
        if isFromDialVC {
            DispatchQueue.main.async {
                let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
                guard let phoneNumber = self.phoneNumbers else {return}
                if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callDialType = 'dial'"), sortDescriptors: [sortDescriptor]) {
                    self.tasks = tasks
                    self.userCallDialedListView.reloadData()
                }
            }
        } else {
        DispatchQueue.main.async {
            let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
            guard let phoneNumber = self.phoneNumbers else {return}
            if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callDialType = 'contact' AND phoneNumber = '\(phoneNumber)'"), sortDescriptors: [sortDescriptor]) {
                self.tasks = tasks
                self.userCallDialedListView.reloadData()
            }
        }
        }
        }

    //MARK: Buttons
    
    @IBAction func callBtnAction(_ sender: UIButton) {
//        performSegue(withIdentifier: "gotoDialer", sender: self)
        if let phoneNumber = phoneNumbers {
            if AppGlobalValues.isCallOngoing {
                if let parentMain = self.parent?.parent, parentMain.isKind(of: MainTabbarController.self), let phoneNumber = phoneNumbers?.first?.phoneNumber {
                    AppGlobalValues.conferenceNumber = phoneNumber
                    AppGlobalValues.conferenceName = self.name ?? ""
                    parentMain.dismiss(animated: true, completion: nil)
                }
            } else {
                if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                    callVC.isFromUserContacts = true
                    callVC.nameOfUser = self.name
                    callVC.phoneNumberOfuser = phoneNumber.first?.phoneNumber
                    callVC.profileImage = self.nameView.image
                    callVC.callDialType = .contact
                    callVC.modalPresentationStyle = .fullScreen
                    self.present(callVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if AppGlobalValues.isCallOngoing {
            if let parentMain = self.parent?.parent, parentMain.isKind(of: MainTabbarController.self), let phoneNumber = phoneNumbers?.first?.phoneNumber {
                AppGlobalValues.conferenceNumber = phoneNumber
                AppGlobalValues.conferenceName = self.name ?? ""
                parentMain.dismiss(animated: true, completion: nil)
            }
        } else {
            if segue.identifier == "gotoDialer" {
                print("Dialer is calling")
                let des = segue.destination as! RTCDialerVC
                des.nameOfUser = self.name
                des.phoneNumberOfuser = phoneNumbers?.first?.phoneNumber
                des.isFromUserContacts = true
                if let av = self.avatarImage {
                    des.image = av
                }
                des.profileImage = self.nameView.image
                //des.whichVC = FromVC.UserContactsListVC
            }
        }
    }
    
    @objc func goToTopup(_ btn: UIButton) {
        
        let point = btn.convert(btn.bounds.origin, to: self.userCallDialedListView)
        
        if let indexPath = self.userCallDialedListView.indexPathForRow(at: point), let cell = self.userCallDialedListView.cellForRow(at: indexPath) as? CallDialedList {
            
            let phoneNo = phoneNumbers![btn.tag]
            
            if AppGlobalValues.isCallOngoing {
                if let parentMain = self.parent?.parent, parentMain.isKind(of: MainTabbarController.self) {
                    AppGlobalValues.conferenceNumber = phoneNo.phoneNumber
                    AppGlobalValues.conferenceName = self.name ?? ""
                    parentMain.dismiss(animated: true, completion: nil)
                }
            } else {
                if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                    callVC.isFromUserContacts = true
                    callVC.nameOfUser = self.name
                    callVC.phoneNumberOfuser = phoneNo.phoneNumber
                    callVC.profileImage = self.nameView.image
                    callVC.callDialType = .contact
                    callVC.modalPresentationStyle = .fullScreen
                    self.present(callVC, animated: true, completion: nil)
                }
            }
        }
    }
}

extension RTCUserContactsDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumbers?.count ?? 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialledCell", for: indexPath) as! CallDialedList
        
        //if phoneNumbers.count >= indexPath.row {
        let callLog = phoneNumbers![indexPath.row]
            
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        
        cell.contactNumber.text = callLog.phoneNumber
        cell.callButton.tag = indexPath.row
        cell.callButton.addTarget(self, action: #selector(goToTopup), for: .touchUpInside)
//            let getStr = dateFormatter.string(from: callLog.startDateTime)
//
//            var strArray = getStr.components(separatedBy: " ")
//
//            //cell.date.text = strArray[0]
//            //cell.hour.text = strArray[1]+strArray[2]
//            if isFromDialVC {
//                cell.date.text = callLog.phoneNumber //task.countryName
//                cell.duration.text = dateFormatter.string(from: callLog.startDateTime)
//                cell.callDurationLabel.text = String(callLog.hourMS)
//            } else {
//            cell.date.text = dateFormatter.string(from: callLog.startDateTime) //task.countryName
//            cell.duration.text = String(callLog.hourMS)
//            }
//
//            if callLog.callType == RTCCallState.missed.rawValue {
//            cell.callTypeIcon.image = UIImage(named: "img_misses")
//            } else {
//                cell.callTypeIcon.image = UIImage(named: "img_outgoing")
//            }
//
       // }
        
        
        
        return cell
    }
    
    
}
