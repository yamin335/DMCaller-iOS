//
//  MRDBManager.swift
//  RTCPhone
//
//  Created by Mamun Ar Rashid on 4/8/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import CoreData

class MRDBManager {
    
    static var savingContext: NSManagedObjectContext = (MRCoreData.defaultStore?.defaultSaveContext()!)!
    
    static var fetchContext: NSManagedObjectContext = (MRCoreData.defaultStore?.defaultFetchContext())!
}
