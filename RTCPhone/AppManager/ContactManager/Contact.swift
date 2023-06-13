//
//  Contact.swift
//  JFContactsPicker
//

import UIKit
import Contacts

/// An instance of this class contains information on a single contact in the users phone.
open class Contact {
    
    /*
     *  MARK: - Instance Properties
     */
    
    /// The first name of the contact.
    open let firstName: String
    
    /// The last name of the contact.
    open let lastName: String
    
    /// The name of the company the contact works for.
    open let company: String
    
    /// A thumbnail image to be displayed on a `UITableViewCell`
    open let thumbnailProfileImage: UIImage?
    
    /// The image to be displayed when the contact is selected.
    open let profileImage: UIImage?
    
    /// The contact's birthday.
    open let birthday: Date?
    
    /// The contact's birthday stored as a string.
    open let birthdayString: String?
    
    /// The unique identifier for the contact in the phone database.
    open let contactId: String?
    
    /// An array of the phone numbers associated with the contact.
    open let phoneNumbers: [(phoneNumber: String, phoneLabel: String)]
    
    /// An array of emails associated with the contact,
    open let emails: [(email: String, emailLabel: String )]
    
    open let favorite: Int16
    
    private static let dateFormatter: DateFormatter = DateFormatter()
    
    /*
     *  MARK: - Computed Properties
     */
    
    open var displayName: String {
        return firstName + " " + lastName
    }
    
    open var initials: String {
        var initials: String = ""
        
        if let firstNameFirstChar = firstName.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = lastName.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
    /*
     *  MARK: - Object Life Cycle
     */
	
    /// The designated initializer for the class.
    ///
    /// - Parameter contact: A `CNContact` instance which supplies all the property values for this class.
    public init (contact: Contacts) {
        firstName = contact.givenName!
        lastName = contact.familyName!
        favorite = contact.favorite
        //company = contact.organizationName
        company = ""
        contactId = contact.identifier
        thumbnailProfileImage = nil
        profileImage = nil
        birthday = nil
        birthdayString = nil
        
//        if let thumbnailImageData = contact.thumbnailImageData {
//            thumbnailProfileImage = UIImage(data:thumbnailImageData)
//        } else {
//            thumbnailProfileImage = nil
//        }
//
//        if let imageData = contact.imageData {
//            profileImage = UIImage(data:imageData)
//        } else {
//            profileImage = nil
//        }
        
//        if let birthdayDate = contact.birthday {
//            birthday = Calendar(identifier: Calendar.Identifier.gregorian).date(from: birthdayDate)
//            Contact.dateFormatter.dateFormat = GlobalConstants.Strings.birthdayDateFormat
//            //Example Date Formats:  Oct 4, Sep 18, Mar 9
//            birthdayString = Contact.dateFormatter.string(from: birthday!)
//
//        } else {
//            birthday = nil
//            birthdayString = nil
//        }
        
        var numbers: [(String, String)] = []
        for phoneNumber in contact.phonenumbers?.allObjects as! [PhoneNumbers] {
			let phoneLabel = phoneNumber.label ?? ""
			let phone = phoneNumber.number
			
            numbers.append((phone!,phoneLabel))
		}
        phoneNumbers = numbers
		
        var emails: [(String, String)] = []
//        for emailAddress in contact.emailAddresses {
//            let emailLabel = emailAddress.label ?? ""
//            let email = emailAddress.value as String
//
//            emails.append((email,emailLabel))
//        }
        self.emails = emails
        
    }
    
}
