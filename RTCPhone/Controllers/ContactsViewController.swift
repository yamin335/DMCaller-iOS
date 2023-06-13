//
//  ContactsViewController.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 1/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//


//
//  ContactsPicker.swift
//  JFContactsPicker
//

import UIKit
import Contacts

/// Objects that conform to this protocol can become a `delegate` for a `ContactsPicker` instance.
public protocol ContactsPickerDelegate: class {
    
    /// This method is called when the `contactPicker` fails to fetch contacts from the `store`.
    ///
    /// - Parameters:
    ///   - _: The contactPicker whose fetch failed.
    ///   - error: An `NSError` instance that describes the failure.
    func contactPicker(_: ContactsViewController, didContactFetchFailed error: NSError)
    
    /// This method is called when the user presses "Cancel" on the `contactPicker`.
    /// The delegate may choose how to respond to this. You may want to dismiss the picker, or respond in some
    /// other way.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - error: An `NSError` instance describing the cancellation.
    func contactPickerDidCancel(_: ContactsViewController)
    
    /// Called when a contact is selected.
    /// - Note: This method is called when `multiSelectEnabled` is `false`. If `multiSelectEnabled` is `true` then
    /// `contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact])` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contact: The `Contact` that was selected by the user.
    func contactPicker(_: ContactsViewController, didSelectContact contact: Contact)
    
    /// Called when the user finishes selecting multiple contacts.
    /// - Note: This method is called when `multiSelectEnabled` is `true`. If `multiSelectEnabled` is `false` then
    /// `func contactPicker(_: ContactsPicker, didSelectContact contact: Contact)` is called instead.
    ///
    /// - Parameters:
    ///   - _: The `contactPicker` instance which called this method.
    ///   - contacts: An array of `Contact`'s selected by the user.
    func contactPicker(_: ContactsViewController, didSelectMultipleContacts contacts: [Contact])
}

public extension ContactsPickerDelegate {
    func contactPicker(_: ContactsViewController, didContactFetchFailed error: NSError) { }
    func contactPickerDidCancel(_: ContactsViewController) { }
    func contactPicker(_: ContactsViewController, didSelectContact contact: Contact) { }
    func contactPicker(_: ContactsViewController, didSelectMultipleContacts contacts: [Contact]) { }
}

typealias ContactsHandler = (_ contacts : [CNContact] , _ error : NSError?) -> Void

public enum SubtitleCellValue{
    case phoneNumber
    case email
    case birthday
    case organization
}

open class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //ContactsViewController
    // MARK: - Properties
    
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    
    /// Contacts ordered in dictionary alphabetically using `sortOrder`.
    private var orderedContacts = [String: [Contacts]]()
    private var sortedContactKeys = [String]()
    
    public private(set) var selectedContacts = [Contact]()
    private var filteredContacts = [Contacts]()
    
    /// The `delegate` for the picker.
    open weak var contactDelegate: ContactsPickerDelegate?
    
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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    //    public lazy var segmentedVC: UISegmentedControl = {
//        let items = ["All", "Favorites"]
//        let segmentedVC = UISegmentedControl(items: items)
//        segmentedVC.selectedSegmentIndex = 0
//        return segmentedVC
//    }()
//
//    public lazy var searchBar: UISearchBar = {
//        let searchBar = UISearchBar(frame: CGRect.zero)
//        searchBar.placeholder = "Search"
//        searchBar.delegate = self
//        return searchBar
//    }()
//
//    public private(set) lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        tableView.delegate = self
//        tableView.dataSource = self
//        return tableView
//    }()
//
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
    public init(delegate: ContactsPickerDelegate? = nil,
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
//
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
                if contacts.count == 0 {
//                    self.progressHUD = ProgressHUDManager(view: self.view)
//                    self.progressHUD?.start()
//                    self.progressHUD?.isNeedShowSpinnerOnly = true
                }
            }
        }
        
        //self.title = GlobalConstants.Strings.contactsTitle
        navigationController?.navigationBar.barTintColor = Theme.navBarTintColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.view.backgroundColor = UIColor.white
        
        //registerContactCell()
        //self.containerView.addSubview(tableView)
        
        
//        tableView.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 178, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        initializeBarButtons()
        //setUpSegmentedControl()
        //setUpSearchBar()
        //reloadContacts()
        
        
        //DispatchQueue.main.async {
        
        //}
       
        
        if let navUtil = AppManager.contactsNavigationBarUtil {
            navigationItem.titleView = navUtil.addView()
        }
        
        DispatchQueue.main.async {
            self.loadContactsToDatabase()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadContacts()
        //self.loadContactsToDatabase()
       
    }
    
//    func setUpSearchBar() {
//        searchBar.sizeToFit()
//        self.view.addSubview(searchBar)
//        searchBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 113, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 65)
//
//        //self.tableView.tableHeaderView = searchBar
//    }
    
//    func setUpSegmentedControl() {
//        segmentedVC.addTarget(self, action: #selector(changeContactType), for: .valueChanged)
//        segmentedVC.sizeToFit()
//        self.view.addSubview(segmentedVC)
//        segmentedVC.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 75, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 28)
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
//            let selectedSegmentIndex = self.segmentedVC.selectedSegmentIndex
            
            var contacts : [Contacts] = []
            contacts = (MRCoreData.defaultStore?.selectAll(sortDescriptors: [sortDescriptor]))!
//            if selectedSegmentIndex == 0{
//                contacts = (MRCoreData.defaultStore?.selectAll(sortDescriptors: [sortDescriptor]))!
//            }
//            else if selectedSegmentIndex == 1{
//                contacts = (MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "favorite = '1'"),sortDescriptors: [sortDescriptor]))!
//            }
            
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
                
                self.contactTableView.reloadData()
                
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
                    
                    if let contactListFromDB:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "identifier = '\(contact.identifier)'")) {
                        // let context = MRCoreData.defaultStore?.defaultSaveContext()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
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
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
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
            self.contactTableView.reloadData()
        }
    }
    
    private func updateContacts(with predicate: String) {
        do {
//            let selectedSegmentIndex = segmentedVC.selectedSegmentIndex
            let sortDescriptor = NSSortDescriptor(key: "givenName", ascending: true)
            if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "givenName contains[c] '\(predicate)' || familyName contains[c] '\(predicate)'"), sortDescriptors: [sortDescriptor]) {
                self.filteredContacts = contacts
            }
//            if selectedSegmentIndex == 0{
//                if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "givenName contains[c] '\(predicate)' || familyName contains[c] '\(predicate)'"), sortDescriptors: [sortDescriptor]) {
//                    self.filteredContacts = contacts
//                }
//            }
//            else if selectedSegmentIndex == 1{
//                if let contacts:[Contacts] = MRCoreData.defaultStore?.selectAll(where: NSPredicate(format: "(givenName contains[c] '\(predicate)' || familyName contains[c] '\(predicate)') && favorite = '1'"), sortDescriptors: [sortDescriptor]) {
//                    self.filteredContacts = contacts
//                }
//            }
            
            
            //filteredContacts = self.filteredContacts.filter({$0.givenName?.contains(predicate) ?? false})
//            if let shouldIncludeContact = shouldIncludeContact {
//                filteredContacts = filteredContacts.filter(shouldIncludeContact)
//            }
            
            self.contactTableView.reloadData()
            
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


/*
 import UIKit
 import SwiftyContacts
 import Contacts
 
 class ContactsViewController: UIViewController {
 let arrIndexSection = ["A","B","C","D", "E", "F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
 @IBOutlet weak var phoneTableView: UITableView!
 @IBOutlet weak var searchNames: UISearchBar!
 var phoneNumbers: [CNContact] = []
 var filteredArray: [ContactsManager] = []
 var isSearching = false
 
 var contacts: [ContactsManager] = []
 var myTableViewRowNumber: Int?
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 navigationController?.navigationBar.barTintColor = UIColor(hex: 0xec1b33)
 navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
 
 self.title = "Contacts"
 
 requestToAccess()
 StatusForAuthorization()
 
 searchNames.returnKeyType = UIReturnKeyType.done
 
 fetchContacts(completionHandler: { (result) in
 switch result{
 case .Success(response: let contacts):
 // Do your thing here with [CNContacts] array
 for contact in contacts {
 let val = (contact.phoneNumbers.first?.value)?.stringValue
 if let v = val {
 let nom = contact.givenName + " " + contact.familyName
 
 
 var avatarImage: UIImage!
 if let imageData = contact.imageData {
 avatarImage = UIImage(data: imageData)!
 }
 
 
 let manager = ContactsManager(names: nom, phoneNumber: v, avatar: avatarImage)
 self.contacts.append(manager)
 
 
 
 
 
 } else {
 let nom = contact.givenName + " " + contact.familyName
 let imageData = contact.imageData
 var avatarImage: UIImage!
 if let dat = imageData {
 avatarImage = UIImage(data: dat)!
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
 
 
 override func viewWillAppear(_ animated: Bool) {
 phoneTableView.reloadData()
 }
 @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
 self.searchNames.resignFirstResponder()
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
 
 extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
 
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
 let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomPhoneCell
 
 if isSearching {
 cell.names.text = filteredArray[indexPath.row].names
 cell.phoneNumbers.text = filteredArray[indexPath.row].phoneNumber
 } else {
 cell.names.text = contacts[indexPath.row].names!
 cell.phoneNumbers.text = contacts[indexPath.row].phoneNumber!
 print("Nmaes of Contacts: \(contacts[indexPath.row].names!) \(contacts[indexPath.row].phoneNumber!)")
 }
 
 return cell
 }
 
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 if let indx = tableView.indexPathForSelectedRow {
 self.myTableViewRowNumber = indx.row
 }
 if let contactsDetailsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RTCUserContactsDetailsVC") as? RTCUserContactsDetailsVC {
 
 if isSearching {
 if let phoneNumber = filteredArray[indexPath.row].phoneNumber {
 contactsDetailsVC.name = self.filteredArray[myTableViewRowNumber!].names
 contactsDetailsVC.phoneNumbers = phoneNumber
 }
 
 } else {
 if let phoneNumber = contacts[indexPath.row].phoneNumber {
 contactsDetailsVC.name = self.contacts[myTableViewRowNumber!].names
 contactsDetailsVC.phoneNumbers = phoneNumber
 }
 
 }
 self.navigationController?.show(contactsDetailsVC, sender: nil)
 
 //present(contactsDetailsVC, animated: true, completion: nil)
 }
 
 // performSegue(withIdentifier: "gotoUserContactsDetailsVC", sender: self)
 }
 
 func sectionIndexTitles(for tableView: UITableView) -> [String]? {
 return arrIndexSection
 }
 
 func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
 
 /*this method will get called when you click on a shortcut and it will scroll the UITableView to the respective section. But in our UITableView we have only one section, so when 'index' is not equal to 0 we'll have write some code to scroll the UITableView.*/
 
 return ([UITableViewIndexSearch] + UILocalizedIndexedCollation.current().sectionIndexTitles as NSArray).index(of: title) - 1
 
 //        if (index != 0) {
 // i is the index of the cell you want to scroll to
 //            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
 //            self.phoneTableView.scrollToRow(at: <#T##IndexPath#>, at: .top, animated: true)
 //        }
 //        return index
 
 }
 
 
 
 func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
 self.searchNames.resignFirstResponder()
 }
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "gotoUserContactsDetailsVC" {
 print("User Details VC")
 let des = segue.destination as! RTCUserContactsDetailsVC
 des.name = self.contacts[myTableViewRowNumber!].names
 des.phoneNumbers = self.contacts[myTableViewRowNumber!].phoneNumber
 if let avatar = self.contacts[myTableViewRowNumber!].avatar {
 des.avatarImage = avatar
 }
 }
 }
 
 }
 
 extension ContactsViewController: UISearchBarDelegate {
 func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
 if searchNames.text == nil || searchNames.text == "" {
 isSearching = false
 phoneTableView.reloadData()
 } else {
 isSearching = true
 searchBar.showsCancelButton = true
 //            var naam = [String]()
 //            for names in self.contacts {
 //                if let nam = names.names {
 //                    naam.append(nam)
 //                }
 //
 //            }
 
 if (searchNames.text?.isPhone())! {
 filteredArray =  self.contacts.filter({($0.phoneNumber?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "").contains(searchNames.text!))!})
 } else {
 filteredArray =  self.contacts.filter({($0.names?.contains(searchNames.text!))!})
 }
 
 //naam.filter({$0.contains(searchNames.text!)})
 phoneTableView.reloadData()
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
 
 */

