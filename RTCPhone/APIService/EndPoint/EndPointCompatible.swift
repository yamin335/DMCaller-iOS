//
//  EndPointCompatible.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import Alamofire

public protocol EndPointCompatible {
    var method: HTTPMethod {get}
    var query: [String: Any] {get}
    var path: String {get}
}

extension EndPointCompatible {
    
    var method: HTTPMethod {
        switch self {
        default :
            return .post
        }
    }
    
    var baseQuery: [String: Any]  {
        return [:]
    }
    
    func getCompleteParameters(parameters: [String: Any]) -> [String: Any] {
        var modifiedQueries: [String: Any] = parameters
        modifiedQueries["DeviceId"] = UIDevice.current.identifierForVendor!.uuidString
        return modifiedQueries
    }
    
    func getCompleteParametersForLogin(parameters: [String: Any]) -> [String: Any] {
        var modifiedQueries: [String: Any] = parameters
        modifiedQueries["DeviceId"] = UIDevice.current.identifierForVendor!.uuidString
        return modifiedQueries
    }
}
