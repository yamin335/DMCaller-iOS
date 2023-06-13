//
//  PhoneDigit.swift
//  DialPad
//
//  Created by Saurav Satpathy on 18/09/17.
//  Copyright © 2017 Saurav Satpathy. All rights reserved.
//

import UIKit

class PhoneDigit: NSObject {
    public var number: String?
    public var letters: String?
    init(number: String, letters: String) {
        self.number = number
        self.letters = letters
    }
}
