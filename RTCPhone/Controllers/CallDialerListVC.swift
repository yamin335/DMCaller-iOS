//
//  CallDialerListVC.swift
//  RTCPhone
//
//  Created by Admin on 4/8/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import CoreData

class CallDialerListVC: UIViewController, CNContactViewControllerDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var listTableView: UITableView!
    var tasks: [CallLog] = []
    var addContact : String = "new"
    var phoneNumber : String = ""
    var selectedSegmentIndex = 0
    var contactsDict = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Call History"
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if let navUtil = AppManager.callHistoryNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        loadData(nil)
    }
    
    @IBAction func changeColor(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSegmentIndex = 0
            loadData(nil)
        case 1:
            selectedSegmentIndex = 1
            loadData(RTCCallState.incoming)
        case 2:
            selectedSegmentIndex = 2
            loadData(RTCCallState.outgouning)
        case 3:
            selectedSegmentIndex = 3
            loadData(RTCCallState.missed)
        // self.view.backgroundColor = UIColor.blueColor()
        default:
            selectedSegmentIndex = 0
            loadData(nil)
            //self.view.backgroundColor = UIColor.purpleColor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        loadContactsFromDatabase()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadContactsDictionary()
        
        switch selectedSegmentIndex {
        case 0:
            loadData(nil)
        case 1:
            loadData(RTCCallState.incoming)
        case 2:
            loadData(RTCCallState.outgouning)
        case 3:
            loadData(RTCCallState.missed)
        // self.view.backgroundColor = UIColor.blueColor()
        default:
            loadData(nil)
            //self.view.backgroundColor = UIColor.purpleColor()
        }
        
//        if let pushcall = UserDefaults.standard.value(forKey: "inactivepush") as? Bool, pushcall, let callerName = UserDefaults.standard.value(forKey: "callerName") as? String, let callerID = UserDefaults.standard.value(forKey: "callerID") as? String , let uuid = UserDefaults.standard.value(forKey: "uuid") as? String {
//          
//            UserDefaults.standard.set(false, forKey: "inactivepush")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                CallManager.currentIncomingCall = IncomingCallInfo(uuid: uuid, callerName: callerName, callerID: callerID,callStatus: .pushReceived)
//                UserDefaults.standard.set(false, forKey: "pushcall")
//                CallManager.presentReceivedCall(fromVC:self,phoneNumber:callerID)
//                //self.selectedIndex  = 4
//                print("pushcall pushcallpushcall")
//                UserDefaults.standard.synchronize()
//            }
//         
//       
//        }
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
                    self.contactsDict = appdelegate.contactsDict
                }
        }
    }
    
    func loadContactsDictionary() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            self.contactsDict = appdelegate.contactsDict
        }
    }
    
    
    func loadData(_ callType: RTCCallState?) {
        //MARK: Edited at 27/06/2018 for updating tableview descending order
        DispatchQueue.main.async {
            let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
            
            //            if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(sortDescriptors: [sortDescriptor])  {
            //                self.tasks = tasks
            ////                self.userCallDialedListView.reloadData()
            //            }
            
            if let callType = callType, let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callType = '\(callType.rawValue)'"), sortDescriptors: [sortDescriptor]) {
                self.tasks = tasks
                self.listTableView.reloadData()
            } else {
                if let tasks:[CallLog] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "callDialType = 'dial' || callDialType = 'contact' || callDialType = 'received' || callType = 'outgouning' || callType = 'incoming' || callType = 'missed'"), sortDescriptors: [sortDescriptor]) {
                    self.tasks = tasks
                    self.listTableView.reloadData()
                }
            }
        }
    }
    
}

extension CallDialerListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialerCallList", for: indexPath) as! DialerCallList
        if tasks.count >= indexPath.row {
            let task = tasks[indexPath.row]
            
            let trimmedUserNumber = task.phoneNumber.replacingOccurrences(of: " ", with: "").trim().suffix(11)
            if let localContactName = contactsDict[String(trimmedUserNumber)], !localContactName.isEmpty {
                cell.dialedPhoneNumber.text = localContactName
                cell.contactImageView.setImageForName(string: localContactName, circular: true, textAttributes: nil)
            } else {
                cell.dialedPhoneNumber.text = String(trimmedUserNumber)
                cell.contactImageView.setImageForName(string: "#", circular: true, textAttributes: nil)
            }
            
//            if !task.phoneUser.trimmingCharacters(in: .whitespaces).isEmpty {
//                cell.dialedPhoneNumber.text = task.phoneUser
//                cell.contactImageView.setImageForName(string: task.phoneUser, circular: true, textAttributes: nil)
//                //cell.addBtn.isHidden = true
//            } else if !task.phoneNumber.isEmpty {
//                cell.dialedPhoneNumber.text = task.phoneNumber
//                cell.contactImageView.setImageForName(string: "#", circular: true, textAttributes: nil)
//            }
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            //let getStr = dateFormatter.string(from: task.startDateTime)
            
            //var strArray = getStr.components(separatedBy: " ")
            
            //cell.date.text = strArray[0]
            // cell.hours.text = strArray[1]+strArray[2]
            cell.time.text = dateFormatter.string(from: task.startDateTime) //task.countryName
            
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            cell.date.text = dateFormatter.string(from: task.startDateTime)
            
            let duration = String(task.hourMS)
            
            if task.callType == RTCCallState.missed.rawValue {
                cell.dialedImageView.image = UIImage(named: "img_misses")
                cell.duration.text = "Missed"
                cell.dialedPhoneNumber.textColor = UIColor.colorFrom(hexString: "D54940")
            } else if task.callType == RTCCallState.incoming.rawValue {
                cell.dialedImageView.image = UIImage(named: "img_incoming")
                //cell.status.text = "Incoming"
                cell.dialedPhoneNumber.textColor = UIColor.darkText
                if duration.isEmpty {
                    cell.duration.text = "Didn't connect"
                } else {
                    cell.duration.text = duration
                }
            } else {
                cell.dialedImageView.image = UIImage(named: "img_outgoing")
                //cell.status.text = "Outgoing"
                cell.dialedPhoneNumber.textColor = UIColor.darkText
                if duration.isEmpty {
                    cell.duration.text = "Didn't connect"
                } else {
                    cell.duration.text = duration
                }
            }
            
            cell.tappedForAddBtn = { [unowned self] (selectedCell) -> Void in
                let path = tableView.indexPathForRow(at: selectedCell.center)!
                let task = self.tasks[path.row]
                //print(task.phoneNumber)
            
                self.phoneNumber = task.phoneNumber
                if !self.phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty {
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let action1 = UIAlertAction(title: "Create New Contact", style: .default) { (action:UIAlertAction) in
                        //print("Create New Contact");
                        self.addContact = "new"
                        let con = CNMutableContact()
                        con.phoneNumbers.append(CNLabeledValue(
                            label: "amberPhone", value: CNPhoneNumber(stringValue: self.phoneNumber)))
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
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppGlobalValues.isCallOngoing {
            if let parentMain = self.parent?.parent, parentMain.isKind(of: MainTabbarController.self) {
                let task = tasks[indexPath.row]
                //callVC.isFromUserContacts = false
                //callVC.nameOfUser = task.phoneUser
                AppGlobalValues.conferenceNumber = task.phoneNumber
                AppGlobalValues.conferenceName = task.phoneUser
                //callVC.profileImage = self.nameView.image
                //callVC.callDialType = .contact
                parentMain.dismiss(animated: true, completion: nil)
            }
        } else {
            let task = tasks[indexPath.row]
            if let callVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCDialerVC") as? RTCDialerVC {
                callVC.isFromUserContacts = false
                callVC.nameOfUser = task.phoneUser
                callVC.phoneNumberOfuser = task.phoneNumber
                //callVC.profileImage = self.nameView.image
                callVC.callDialType = .contact
                callVC.modalPresentationStyle = .fullScreen
                self.present(callVC, animated: true, completion: nil)
            }
        }
        // }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete")
            let alert = UIAlertController(title: "Delete", message: "Are you sure ?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
                self.deleteCallHistoryFromDatabase(indexPath: indexPath)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func deleteCallHistoryFromDatabase(indexPath: IndexPath){
        
        //let sortDescriptor = NSSortDescriptor(key: "startDateTime", ascending: false)
        
        let deleteObject =  self.tasks[indexPath.row]

        if let context = MRCoreData.defaultStore?.backgroundTheadDeleteContext() {

            let obj = context.object(with: deleteObject.objectID)
            context.delete(obj)

            do {
                try context.save() // <- remember to put this :)
            } catch(let error) {
                print(error)
            }
        }
        
//        let fetchRequest = CallLog.fetchRequest()
//
//        let predicate = NSPredicate(format: "phoneNumber = '"+(deleteObject.phoneNumber)+"'")
//
//        fetchRequest.predicate = predicate
//
//
//        if let context = MRCoreData.defaultStore?.backgroundTheadDeleteContext(), let objects = try? context.fetch(fetchRequest) {
//
//            for obj in objects {
//                context.delete(obj as! NSManagedObject)
//            }
//
//            do {
//                try context.save() // <- remember to put this :)
//            } catch(let error) {
//                print(error)
//            }
//        }
        
        self.tasks.remove(at: indexPath.row)
        self.listTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    //MARK: CNContactPickerDelegate methods
    // The selected person and property from the people picker.
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        DispatchQueue.main.async() {
            let con = contact.mutableCopy() as! CNMutableContact
            con.phoneNumbers.append(CNLabeledValue(label: "amberPhone", value: CNPhoneNumber(stringValue: self.phoneNumber)))
            let npvc = CNContactViewController(forNewContact: con)
            npvc.delegate = self
            npvc.setEditing(true, animated: true)
            npvc.title = "Update Contact"
            
            let navigation = UINavigationController(rootViewController: npvc)
            self.present(navigation, animated: true, completion: nil)
        }

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
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
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
                                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
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
    
}

