//
//  FavoriteViewController.swift
//  RTCPhone
//
//  Created by Md. Yamin on 3/20/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import Contacts

/// Objects that conform to this protocol can become a `delegate` for a `ContactsPicker` instance.
public protocol FavoriteContactsPickerDelegate: class {
    
    /// This method is called when the `contactPicker` fails to fetch contacts from the `store`.
    ///
    /// - Parameters:
    ///   - _: The contactPicker whose fetch failed.
    ///   - error: An `NSError` instance that describes the failure.
    func contactPicker(_: FavoriteViewController, didContactFetchFailed error: NSError)
    
    /// This method is called when the user presses "Cancel" on the `contactPicker`.
    /// The delegate may choose how to respond to this. You may want to dismiss the picker, or respond in some
    /// other way.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - error: An `NSError` instance describing the cancellation.
    func contactPickerDidCancel(_: FavoriteViewController)
    
    /// Called when a contact is selected.
    /// - Note: This method is called when `multiSelectEnabled` is `false`. If `multiSelectEnabled` is `true` then
    /// `contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact])` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contact: The `Contact` that was selected by the user.
    func contactPicker(_: FavoriteViewController, didSelectContact contact: Contact)
    
    /// Called when the user finishes selecting multiple contacts.
    /// - Note: This method is called when `multiSelectEnabled` is `true`. If `multiSelectEnabled` is `false` then
    /// `func contactPicker(_: ContactsPicker, didSelectContact contact: Contact)` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contacts: An array of `Contact`'s selected by the user.
    func contactPicker(_: FavoriteViewController, didSelectMultipleContacts contacts: [Contact])
}

public extension FavoriteContactsPickerDelegate {
    func contactPicker(_: FavoriteViewController, didContactFetchFailed error: NSError) { }
    func contactPickerDidCancel(_: FavoriteViewController) { }
    func contactPicker(_: FavoriteViewController, didSelectContact contact: Contact) { }
    func contactPicker(_: FavoriteViewController, didSelectMultipleContacts contacts: [Contact]) { }
}

open class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //FavoriteViewController
    // MARK: - Properties
    
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    
    /// Contacts ordered in dictionary alphabetically using `sortOrder`.
    private var orderedContacts = [String: [Contacts]]()
    private var sortedContactKeys = [String]()
    
    public private(set) var selectedContacts = [Contact]()
    private var filteredContacts = [Contacts]()
    
    /// The `delegate` for the picker.
    open weak var contactDelegate: FavoriteContactsPickerDelegate?
    
    /// If `true`, the picker will allow multiple contacts to be selected.
    /// Defaults to `false` for single contact selection.
    public let multiSelectEnabled: Bool
    
    /// Indicates if the index bar should be shown. Defaults to `true`.
    public var shouldShowIndexBar: Bool
    
    /// The contact value type to display in the cells' subtitle labels.
    public let subtitleCellValue: SubtitleCellValue
    
    /// The order that the contacts should be sorted.
    public var sortOrder: CNContactSortOrder = CNContactSortOrder.userDefault {
        didSet {
            if viewIfLoaded != nil {
                self.reloadContacts()
            }
        }
    }
    
    //Enables custom filtering of contacts.
    public var shouldIncludeContact: ((CNContact) -> Bool)? {
        didSet {
            if viewIfLoaded != nil {
                self.reloadContacts()
            }
        }
    }
    
//    public lazy var searchBar: UISearchBar = {
//        let searchBar = UISearchBar(frame: CGRect.zero)
//        searchBar.placeholder = "Search"
//        searchBar.delegate = self
//        return searchBar
//    }()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var favoriteContactsTableView: UITableView!
    //    public private(set) lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        tableView.delegate = self
//        tableView.dataSource = self
//        return tableView
//    }()
    
//    public  lazy var containerView: UIView = {
//        let tableView = UIView(frame: CGRect.zero)
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        return tableView
//    }()
    
    // MARK: - Initializers
    
    /// The designated initializer.
    ///
    /// - Parameters:
    ///   - delegate:           The delegate for the picker. Defaults to `nil`.
    ///   - multiSelection:     `true` for multiple selection, `false` for single selection. Defaults to `false`.
    ///   - showIndexBar:       `true` to show the index bar, `false` to hide the index bar. Defaults to `true`.
    ///   - subtitleCellType:   The value type to display in the subtitle label on the contact cells.
    ///                         Defaults to `.phoneNumber`.
    public init(delegate: FavoriteContactsPickerDelegate? = nil,
                multiSelection: Bool = false,
                showIndexBar: Bool = true,
                subtitleCellType: SubtitleCellValue = .phoneNumber) {
        self.multiSelectEnabled = multiSelection
        self.subtitleCellValue = subtitleCellType
        self.shouldShowIndexBar = showIndexBar
        
        super.init(nibName: nil, bundle: nil)
        
        contactDelegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.multiSelectEnabled = false
        self.subtitleCellValue = .phoneNumber
        self.shouldShowIndexBar = true
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle Methods
    
//    open override func loadView() {
//        self.view = containerView
//    }
    
    //var progressHUD: ProgressHUDManager?
    
    @objc func changeContactType(sender: UISegmentedControl) {
        reloadContacts()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.5960784314, blue: 0.8392156863, alpha: 1)
        
        // start loader for first time load
        DispatchQueue.main.async {
            if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll() {
                if contacts.count == 0{
//                    self.progressHUD = ProgressHUDManager(view: self.view)
//                    self.progressHUD?.start()
//                    self.progressHUD?.isNeedShowSpinnerOnly = true
                }
            }
        }
        
        //self.title = GlobalConstants.Strings.favoritesTitle
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.view.backgroundColor = UIColor.white
        
        //registerContactCell()
        //self.containerView.addSubview(tableView)
        
        
//        tableView.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 178, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        initializeBarButtons()
        //setUpSearchBar()
        //reloadContacts()
        
        
        //DispatchQueue.main.async {
        
        //}
       
        
        if let navUtil = AppManager.favoritesNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        
        DispatchQueue.main.async {
            self.loadContactsToDatabase()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadContacts()
        //
       
    }
    
//    func setUpSearchBar() {
//        searchBar.sizeToFit()
//        self.view.addSubview(searchBar)
//        searchBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 113, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 65)
//
//        //self.tableView.tableHeaderView = searchBar
//    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    
    func initializeBarButtons() {
        //        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(onTouchCancelButton))
        //        self.navigationItem.leftBarButtonItem = cancelButton
        //
        //        if multiSelectEnabled {
        //            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(onTouchDoneButton))
        //            self.navigationItem.rightBarButtonItem = doneButton
        //
        //        }
    }
    
//    private func registerContactCell() {
//        let podBundle = Bundle(for: self.classForCoder)
//        if let bundleURL = podBundle.url(forResource: GlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
//
//            if let bundle = Bundle(url: bundleURL) {
//
//                let cellNib = UINib(nibName: GlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
//                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
//            }
//            else {
//                assertionFailure("Could not load bundle")
//            }
//
//        } else {
//            let cellNib = UINib(nibName: GlobalConstants.Strings.cellNibIdentifier, bundle: podBundle)
//            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
//        }
//    }
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        
        DispatchQueue.main.async {
            let sortDescriptor = NSSortDescriptor(key: "givenName", ascending: true)
            
            var contacts : [Contacts] = []
            contacts = (MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "favorite = '1'"),sortDescriptors: [sortDescriptor]))!
            
            //if contacts.count > 0 {
                self.filteredContacts = contacts
                if let searchText = self.searchBar.text, !searchText.isEmpty {
                    self.updateContacts(with: searchText)
                }
                
                var orderedContacts = [String : [Contacts]]()
                
                for contact in contacts {
                    
                    var key: String = "A"
                    //
                    //                    //If ordering has to be happening via family name change it here.
                    if let firstLetter = self.firstLetter(for: contact) {
                        key = firstLetter.uppercased()
                    }
                    //
                    var contactsForKey = orderedContacts[key] ?? [Contacts]()
                    contactsForKey.append(contact)
                    orderedContacts[key] = contactsForKey
                }
                
                self.orderedContacts = orderedContacts
                
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                    appdelegate.orderedContacts = self.orderedContacts
                }
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    //self.sortedContactKeys.append("#")
                }
                
                self.favoriteContactsTableView.reloadData()
                
            //}
        }

    }
    
    private func loadContactsToDatabase() {
        // TODO: Set up error domain
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
                try self.contactsStore.enumerateContacts(with: contactFetchRequest, usingBlock: { [weak self] (contact, stop) -> Void in
                    
                    //Adds the `contact` to the `contactsArray` if the closure returns true.
                    //If the closure doesn't exist, then the contact is added.
                    if let shouldIncludeContactClosure = self?.shouldIncludeContact, !shouldIncludeContactClosure(contact) {
                        return
                    }
                    
                    if let contactListFromDB: [Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(contact.identifier)'")) {
                        // , let context = MRCoreData.defaultStore?.defaultSaveContext()
                        // Update Contact
                        if contactListFromDB.count > 0 {
//                            let newContact = context.object(with: contactListFromDB[0].objectID) as? Contacts
//                            newContact?.givenName = contact.givenName
//                            newContact?.familyName = contact.familyName
//
//                            // delete old phoneNumbers
//                            let context2 = MRCoreData.defaultStore?.defaultDeleteContext()
//                            if let phoneNumbers = contactListFromDB[0].phonenumbers?.allObjects as? [PhoneNumbers] {
//                                for phoneNumber in phoneNumbers {
//                                    let deletedPhoneNumber = context2?.object(with: phoneNumber.objectID) as? PhoneNumbers
//                                    newContact?.removeFromPhonenumbers(deletedPhoneNumber!)
//                                    context2?.delete(deletedPhoneNumber!)
//                                    do {
//                                        try context2?.save()
//                                    } catch{
//                                        print(error.localizedDescription)
//                                    }
//                                }
//                            }
//
//                            // Add new updated phoneNumbers
//                            for phoneNumber in contact.phoneNumbers {
//                                let newPhoneNumber = PhoneNumbers(context: MRDBManager.savingContext)
//                                newPhoneNumber.identifier = phoneNumber.identifier
//                                newPhoneNumber.label = phoneNumber.label ?? ""
//                                newPhoneNumber.number = phoneNumber.value.stringValue
//
//                                newContact?.addToPhonenumbers(newPhoneNumber)
//                            }
//
//                            do {
//                                try context.save()
//                            } catch {
//                                print(error.localizedDescription)
//                            }
                            //self?.progressHUD?.onSucceed()
                            
                            //self?.reloadContacts()

//                            if let context = MRCoreData.defaultStore?.defaultSaveContext() {
//                                let newContact = context.object(with: contacts[0].objectID) as? Contacts
//                                newContact?.givenName = contact.givenName
//                                newContact?.familyName = contact.familyName
//
//                                newContact?.removeFromPhonenumbers(contacts[0].phonenumbers!)
//
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
//                                }
//                                catch {
//                                    print(error.localizedDescription)
//                                }
//                            }
                            
                        }
                        else{
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
                
                // hide loader
                
                //completion(sortedContactsArray, nil)
                
            } catch let error as NSError {
                /// Catching exception as enumerateContactsWithFetchRequest can throw errors
                print(error.localizedDescription)
            }
                
                //self.progressHUD?.onSucceed()
                
                self.reloadContacts()

            }
        }
    }
    
    private func firstLetter(for contact: Contacts) -> String? {
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
            firstCharacter = contact.givenName!.first
        }
        
        guard let letter = firstCharacter else { return nil }
        let firstLetter = String(letter)
        return firstLetter.containsAlphabets() ? firstLetter : nil
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
    
    // MARK: - Table View DataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        if let searchText = searchBar.text, !searchText.isEmpty { return 1 }
        return sortedContactKeys.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchText = searchBar.text, !searchText.isEmpty { return filteredContacts.count }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            //print(contactsForSection.count)
            return contactsForSection.count
        }
        return 0
    }
    
    // MARK: - Table View Delegates
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteContactCell", for: indexPath) as! FavoriteContactCell
        cell.accessoryType = UITableViewCell.AccessoryType.none
        //Convert CNContact to Contact
        let contact: Contact
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            contact = Contact(contact: filteredContacts[(indexPath as NSIndexPath).row])
            
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            
            contact = Contact(contact: contactsForSection[(indexPath as NSIndexPath).row])
        }
        
        //        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
        //            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        //        }
        
        DispatchQueue.main.async {
            cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: self.subtitleCellValue)
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteContactCell
        let selectedContact =  cell.contact!
        
        if let contactsDetailsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCUserContactsDetailsVC") as? RTCUserContactsDetailsVC {
            
            if searchBar.isFirstResponder { searchBar.resignFirstResponder() }
            
            contactsDetailsVC.name = selectedContact.displayName
            contactsDetailsVC.phoneNumbers = selectedContact.phoneNumbers
            contactsDetailsVC.identifier = selectedContact.contactId
            contactsDetailsVC.favorite = selectedContact.favorite
            
            //            if isSearching {
            //                if let phoneNumber = filteredArray[indexPath.row].phoneNumber {
            //                    contactsDetailsVC.name = self.filteredArray[myTableViewRowNumber!].names
            //                    contactsDetailsVC.phoneNumbers = phoneNumber
            //                }
            //
            //            } else {
            //                if let phoneNumber = contacts[indexPath.row].phoneNumber {
            //                    contactsDetailsVC.name = self.contacts[myTableViewRowNumber!].names
            //                    contactsDetailsVC.phoneNumbers = phoneNumber
            //                }
            //
            //            }
            self.navigationController?.show(contactsDetailsVC, sender: nil)
            
            //present(contactsDetailsVC, animated: true, completion: nil)
        }
        
        //        if multiSelectEnabled {
        //            //Keeps track of enable=ing and disabling contacts
        //            if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
        //                cell.accessoryType = UITableViewCellAccessoryType.none
        //                selectedContacts = selectedContacts.filter(){
        //                    return selectedContact.contactId != $0.contactId
        //                }
        //            }
        //            else {
        //                cell.accessoryType = UITableViewCellAccessoryType.checkmark
        //                selectedContacts.append(selectedContact)
        //            }
        //        }
        //        else {
        //            //Single selection code
        //            if searchBar.isFirstResponder { searchBar.resignFirstResponder() }
        //            self.contactDelegate?.contactPicker(self, didSelectContact: selectedContact)
        //        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let searchText = searchBar.text, !searchText.isEmpty { return 0 }
        return sortedContactKeys.index(of: title)!
    }
    
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if shouldShowIndexBar {
            if let searchText = searchBar.text, !searchText.isEmpty { return nil }
            return sortedContactKeys
        } else {
            return nil
        }
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let searchText = searchBar.text, !searchText.isEmpty { return nil }
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    @objc func onTouchCancelButton() {
        contactDelegate?.contactPickerDidCancel(self)
    }
    
    @objc func onTouchDoneButton() {
        contactDelegate?.contactPicker(self, didSelectMultipleContacts: selectedContacts)
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchBar)
    }
    
    open func updateSearchResults(for searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            //let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: searchText)
            updateContacts(with: searchText)
            
        } else {
            self.favoriteContactsTableView.reloadData()
        }
    }
    
    private func updateContacts(with predicate: String) {
        do {
            let sortDescriptor = NSSortDescriptor(key: "givenName", ascending: true)
           
            if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "(givenName contains[c] '\(predicate)' || familyName contains[c] '\(predicate)') && favorite = '1'"), sortDescriptors: [sortDescriptor]) {
                self.filteredContacts = contacts
            }
            
            
//            filteredContacts = self.filteredContacts.filter({$0.givenName?.contains(predicate) ?? false})
//            if let shouldIncludeContact = shouldIncludeContact {
//                filteredContacts = filteredContacts.filter(shouldIncludeContact)
//            }
            
            self.favoriteContactsTableView.reloadData()
            
        }
        catch {
            contactDelegate?.contactPicker(self, didContactFetchFailed: NSError(domain: "JFContactsPickerErrorDomain",
                                                                                code: 3,
                                                                                userInfo: [ NSLocalizedDescriptionKey: "Failed to fetch contacts"]))
        }
        
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        searchBar.text = nil
        
        DispatchQueue.main.async(execute: {
            searchBar.resignFirstResponder()
        })
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async(execute: {
            searchBar.setShowsCancelButton(false, animated: true)
            self.updateSearchResults(for: searchBar)
        })
    }
    
}
