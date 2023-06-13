//
//  ConferenceRoomCollectionViewCell.swift
//  RTCPhone
//
//  Created by Admin on 4/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

protocol PhotoCellDelete: class {
    func deleteCell(cell: ConferenceRoomCollectionViewCell)
}


class ConferenceRoomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var conferenceUserIconView: UIImageView!
    
    @IBOutlet weak var contactsName: UILabel!
    @IBOutlet weak var deleteButtonBackgroundView: UIVisualEffectView! {
        didSet {
            self.deleteButtonBackgroundView.layer.cornerRadius = self.deleteButtonBackgroundView.bounds.width/2 + 5
            self.deleteButtonBackgroundView.clipsToBounds = true
            self.deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    
    weak var delegate: PhotoCellDelete?
    
    var isEditing: Bool = false {
        didSet {
            self.deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate?.deleteCell(cell: self)
    }
}
