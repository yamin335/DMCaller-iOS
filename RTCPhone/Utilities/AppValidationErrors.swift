//
//  AppValidationErrors.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

public enum ValidationErrors: Error {
    case error
    case invalidName
    case invalidMobile
    case passwordNotMatched
    case invalidEmail
    case outSideBD
    
    var description: String {
        switch self {
        case .error:
            return "Error"
        case .invalidName:
            return "Invalid name"
        case .invalidMobile:
            return "Invalid mobile number"
        case .passwordNotMatched:
            return "Password doesn't matched"
        case .invalidEmail:
            return "Invalid email address"
        case .outSideBD:
            return "You are outside of Bangladesh"
        }
    }
}
