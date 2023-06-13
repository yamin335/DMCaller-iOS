//
//  RTCAddNewMembersVC.swift
//  RTCPhone
//
//  Created by Admin on 4/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import SwiftyContacts
import Contacts

class RTCAddNewMembersVC: UIViewController {
    
    let arrIndexSection = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    @IBOutlet var tapgestureForKeyboardDismiss: UITapGestureRecognizer!
    @IBOutlet weak var searchbarForNewMembers: UISearchBar!
    @IBOutlet weak var newMembersTableView: UITableView!
    var phoneNumbers: [CNContact] = []    
    var contacts: [ContactsManager] = []
    var filteredArray: [ContactsManager] = []
    
    var isSearching: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add New Members"
        navigationController?.navigationBar.tintColor = .white
        
        requestToAccess()
        StatusForAuthorization()
        searchbarForNewMembers.returnKeyType = UIReturnKeyType.done
        fetchContacts(completionHandler: { (result) in
            switch result{
            case .Success(response: let contacts):
                // Do your thing here with [CNContacts] array
                for contact in contacts {
                    let val = (contact.phoneNumbers.first?.value)?.stringValue
                    if let v = val {
                        let nom = contact.givenName + " " + contact.familyName
                        
                        var avatarImage: UIImage?
                        if let imageData = contact.imageData {
                            avatarImage = UIImage(data: imageData)
                        }
                        
                        
                        let manager = ContactsManager(names: nom, phoneNumber: v, avatar: avatarImage)
                        self.contacts.append(manager)
                        
                    } else {
                        let nom = contact.givenName + " " + contact.familyName
                        var avatarImage: UIImage?
                        if let imageData = contact.imageData {
                            avatarImage = UIImage(data: imageData)
                        }
                        let manager = ContactsManager(names: nom, phoneNumber: "", avatar: avatarImage)
                        self.contacts.append(manager)
                    }
                    
                }
                
                
                break
            case .Error(error: let error):
                print(error)
                break
            }
        })    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapGestureForResponder(_ sender: UITapGestureRecognizer) {
        if tapgestureForKeyboardDismiss.state == .began {
            self.newMembersTableView.allowsSelection = false
            
        }
        
        self.searchbarForNewMembers.resignFirstResponder()
        
    }
    
    
    func requestToAccess() {
        requestAccess { (responce) in
            if responce{
                print("Contacts Acess Granted")
            } else {
                print("Contacts Acess Denied")
            }
        }
    }
    
    func StatusForAuthorization() {
        authorizationStatus { (status) in
            switch status {
            case .authorized:
                print("authorized")
                break
            case .denied:
                print("denied")
                break
            default:
                break
            }
        }
    }
    
    
}

//MARK:- TableviewDelegates goes here
extension RTCAddNewMembersVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredArray.count
        }
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMemberCell", for: indexPath) as! NewMemberTableViewCell
        if isSearching {
            cell.names.text = filteredArray[indexPath.row].names
            cell.phoneNumbers.text = filteredArray[indexPath.row].phoneNumber!
        } else {
            cell.names.text = contacts[indexPath.row].names!
            cell.phoneNumbers.text = contacts[indexPath.row].phoneNumber!
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if isSearching {
            
            let selectedContact = filteredArray[indexPath.row]
            ConferenceMemberListManager.currentConferenceList.append(selectedContact)
            self.navigationController?.popViewController(animated: true)
            
         } else {
            let selectedContact = contacts[indexPath.row]
            ConferenceMemberListManager.currentConferenceList.append(selectedContact)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchbarForNewMembers.resignFirstResponder()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return arrIndexSection
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        /*this method will get called when you click on a shortcut and it will scroll the UITableView to the respective section. But in our UITableView we have only one section, so when 'index' is not equal to 0 we'll have write some code to scroll the UITableView.*/
        
        return ([UITableView.indexSearch] + UILocalizedIndexedCollation.current().sectionIndexTitles as NSArray).index(of: title) - 1
        
        //        if (index != 0) {
        // i is the index of the cell you want to scroll to
        //            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
        //            self.phoneTableView.scrollToRow(at: <#T##IndexPath#>, at: .top, animated: true)
        //        }
        //        return index
        
    }

}


//MARK: Searchbar Delegates goes here
extension RTCAddNewMembersVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchbarForNewMembers.text == nil || searchbarForNewMembers.text == "" {
            isSearching = false
            newMembersTableView.reloadData()
        } else {
            isSearching = true
            searchBar.showsCancelButton = true
            var naam = [String]()
            for names in self.contacts {
                if let nam = names.names {
                    naam.append(nam)
                }
                
            }
            
            if (searchbarForNewMembers.text?.isPhone())! {
                filteredArray =  self.contacts.filter({($0.phoneNumber?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "").contains(searchbarForNewMembers.text!))!})
            } else {
                filteredArray =  self.contacts.filter({($0.names?.contains(searchbarForNewMembers.text!))!})
                
            }
           
            newMembersTableView.reloadData()
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        isSearching = false
        searchBar.resignFirstResponder()
    }
}
