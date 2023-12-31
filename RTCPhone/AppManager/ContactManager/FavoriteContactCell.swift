//
//  FavoriteContactCell.swift
//  RTCPhone
//
//  Created by Md. Yamin on 3/21/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class FavoriteContactCell: UITableViewCell {

    @IBOutlet weak var contactTextLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    
    var contact: Contact?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        selectionStyle = UITableViewCell.SelectionStyle.none
//        contactContainerView.layer.masksToBounds = true
//        contactContainerView.layer.cornerRadius = contactContainerView.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    func updateInitialsColorForIndexPath(_ indexpath: IndexPath) {
//        //Applies color to Initial Label
//        let colorArray = GlobalConstants.Colors.all
//        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
//        contactInitialLabel.backgroundColor = colorArray[randomValue]
//    }
 
    func updateContactsinUI(_ contact: Contact, indexPath: IndexPath, subtitleType: SubtitleCellValue) {
        self.contact = contact
        //Update all UI in the cell here
        
        if contact.displayName.trim().isEmpty {
            let phoneNumberCount = contact.phoneNumbers.count
            
            if phoneNumberCount >= 1  {
                self.contactTextLabel?.text = "\(contact.phoneNumbers[0].phoneNumber)"
            }
            self.contactImageView.setImageForName(string: "#", circular: true, textAttributes: nil)
        } else {
            self.contactTextLabel?.text = contact.displayName
            self.contactImageView.setImageForName(string: contact.displayName, circular: true, textAttributes: nil)
        }
        
        //updateSubtitleBasedonType(subtitleType, contact: contact)
//        if contact.thumbnailProfileImage != nil {
//            self.contactImageView?.image = contact.thumbnailProfileImage
//            self.contactImageView.isHidden = false
//            self.contactInitialLabel.isHidden = true
//        } else {
//            self.contactInitialLabel.text = contact.initials
//            updateInitialsColorForIndexPath(indexPath)
//            self.contactImageView.isHidden = true
//            self.contactInitialLabel.isHidden = false
//        }
    }
    
//    func updateSubtitleBasedonType(_ subtitleType: SubtitleCellValue , contact: Contact) {
//
//        switch subtitleType {
//
//        case SubtitleCellValue.phoneNumber:
//            let phoneNumberCount = contact.phoneNumbers.count
//
//            if phoneNumberCount == 1  {
//                self.contactDetailTextLabel.text = "\(contact.phoneNumbers[0].phoneNumber)"
//            }
//            else if phoneNumberCount > 1 {
//                self.contactDetailTextLabel.text = "\(contact.phoneNumbers[0].phoneNumber) and \(contact.phoneNumbers.count-1) more"
//            }
//            else {
//                self.contactDetailTextLabel.text = GlobalConstants.Strings.phoneNumberNotAvaialable
//            }
//        case SubtitleCellValue.email:
//            let emailCount = contact.emails.count
//
//            if emailCount == 1  {
//                self.contactDetailTextLabel.text = "\(contact.emails[0].email)"
//            }
//            else if emailCount > 1 {
//                self.contactDetailTextLabel.text = "\(contact.emails[0].email) and \(contact.emails.count-1) more"
//            }
//            else {
//                self.contactDetailTextLabel.text = GlobalConstants.Strings.emailNotAvaialable
//            }
//        case SubtitleCellValue.birthday:
//            self.contactDetailTextLabel.text = contact.birthdayString
//        case SubtitleCellValue.organization:
//            self.contactDetailTextLabel.text = contact.company
//        }
//    }

}
