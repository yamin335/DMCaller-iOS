//
//  PhoneNumberFormating.swift
//  CashBaba
//
//  Created by Mohammad Arif Hossain on 3/21/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//

import Foundation

class PhoneNumberFormating {
   
    
    
   class func phoneNumberFormatter(phNumber : String) -> String {
        let selectedNumber = phNumber
        let itemSet: [Character] = ["1","2","3","4","5","6","7","8","9","0"]
        var formattedString : String = ""
    
    let onlyPhoneNumber = phNumber.map({ char -> Character in
    if itemSet.contains(char) {
        return char
    } else {
        return "-"
        }
    })
//        for word in selectedNumber {
//            print(word)
//            if itemSet.contains(word){
//                print(word)
//                formattedString = formattedString + String(word)
//            }
//        }
//
//        print(formattedString)
//
        return String(onlyPhoneNumber).replacingOccurrences(of: "-", with: "")
    }
 
    
}
