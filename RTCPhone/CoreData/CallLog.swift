//
//  CallLog.swift
//  RTCPhone
//
//  Created by Admin on 1/8/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import CoreData

open class CallLog: NSManagedObject {
   
    @NSManaged open var startDateTime: Date
    @NSManaged open var endDateTime: Date
    @NSManaged open var hourMS: String
    @NSManaged open var duration: Double
    @NSManaged open var callDialType: String
    @NSManaged open var phoneNumber: String
    @NSManaged open var phoneUser: String
    @NSManaged open var callType: String
    
    public convenience required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
