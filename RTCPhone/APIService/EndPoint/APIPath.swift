//
//  APIPath.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

enum APIPath {
    case basePath(path: String)
    
    var url: String {
        switch self {
        case .basePath(let path): return basePath + path
        }
    }
    private var basePath: String {
        return APIConfiguration.baseURL
    }
}

func queryBuilder(queries: [(name:String, value:Any)]) -> [String: Any] {
    var queryItems:[String: Any] = [String: Any]()
    for query in queries {
        
        if query.name.isEmpty {
            continue
        }
        if let value = query.value as? String, value.isEmpty {
            continue
        }
        
        queryItems[query.name] = query.value
    }
    return queryItems
}
