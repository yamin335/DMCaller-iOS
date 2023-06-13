//
//  CommonUtils.swift
//  CashBaba
//
//  Created by Mamun Ar Rashid on 4/11/18.
//  Copyright © 2018 Recursion Technologies Ltd. All rights reserved.
//

import Foundation

class CommonUtils {
    
    class func calculateProfilePercentage(_ pvalue: String) -> String {
        
        let value = pvalue.trim()
        let length = value.trim().count
        var numberOfOne: Float = 0
        
        if length > 0 {
            for char in value {
                if char == "1" {
                    numberOfOne = numberOfOne + 1
                }
            }
        }
        
        if numberOfOne > 0 {
           let percentage = (numberOfOne/Float(length)) * 100
           let percentageFormat = String(format: "%.0f", percentage)
           return percentageFormat + "%"
        }
        
        return "0%"
    }
}
