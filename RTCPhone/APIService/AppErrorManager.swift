//
//  AppErrorManager.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

public enum AppError: Error {
    case error(Error)
    case dataParsingError(Error)
    case badRequest
    case unauthorised
    case notAllowed
    case notFound
    case internalServerError
    case serverError(Error)
    case sessionExpired
    case notReachable
    
    var localizedDescription: String {
        switch self {
        case .dataParsingError(let err):
            return err.localizedDescription
        case .error(let err):
            return err.localizedDescription
        case .serverError(let err):
            return err.localizedDescription
        case .sessionExpired:
            return ""
        case .notReachable:
            return ""
        
        case .badRequest:
            return ""
        case .unauthorised:
            return ""
        case .notAllowed:
            return ""
        case .notFound:
            return "Not found"
        case .internalServerError:
            return ""
        }
    }
}
