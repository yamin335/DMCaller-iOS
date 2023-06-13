//
//  MRCoreData.swift
//  MRCoreData
//
//  Created by Mamun Ar Rashid on 7/23/17.
//  Copyright © 2017 Fantasy Apps. All rights reserved.
//
import CoreData
import UIKit
import CoreFoundation

enum MRCoreDataError: Error {
    case creationError(message: String)
    case insufficientFunds(message: String)
}
protocol MRCoreDataOperatable {
    func saveAndWait()
}

class MRCoreData {
    
    static var defaultStore: MRCoreDataStore?
    
    public class func makeAndGetStore(dataModelName storeName: String, storeDirectory:
        FileManager.SearchPathDirectory = .documentDirectory) throws -> MRCoreDataStore {
        if storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw MRCoreDataError.creationError(message: "MRCoreDataError: Store Name Cannot be empty")
        }
        var mrCoreData: MRCoreDataStore
        do {
            mrCoreData = try MRCoreDataStore(storeName: storeName, storeDirectory: storeDirectory)
            guard let _ = MRCoreData.defaultStore else {
                MRCoreData.defaultStore = mrCoreData
                return mrCoreData
            }
        } catch {
            throw error
        }
        return mrCoreData
    }
}

class MRCoreDataStore {
    
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var asyncDataFetchContext: NSManagedObjectContext?
    private var mainContext: NSManagedObjectContext?
    private var ayncSaveOrDeleteContext: NSManagedObjectContext?
    private var managedObjectModel: NSManagedObjectModel?
    
    private var storeName: String
    private var storeDirectory: FileManager.SearchPathDirectory
    
    init(storeName: String, storeDirectory: FileManager.SearchPathDirectory) throws {
        self.storeName = storeName
        self.storeDirectory = storeDirectory
        do {try createStore()}catch{ throw error }
    }
    
    public func selectFirst<T:NSManagedObject>(_ predicate: NSPredicate?) -> T? {
        if let context =  self.backgroundTheadFetchContext() {
            let fetchRequest = T.fetchRequest()
            fetchRequest.predicate = predicate
            let results = try! context.fetch(fetchRequest) as! [T]
            return results.first
        }
        return nil
    }
    
    public func selectLast<T:NSManagedObject>(_ predicate: NSPredicate?) -> T? {
        if let context =  self.backgroundTheadFetchContext() {
            let fetchRequest = T.fetchRequest()
            fetchRequest.predicate = predicate
            let results = try! context.fetch(fetchRequest) as! [T]
            return results.last
        }
        return nil
    }
    
    public func selectAll<T:NSManagedObject>(sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {
        if let context =  self.backgroundTheadFetchContext() {
            let fetchRequest = T.fetchRequest()
            if let sortDescriptors = sortDescriptors {
                fetchRequest.sortDescriptors = sortDescriptors
            }
            let results = try! context.fetch(fetchRequest) as! [T]
            return results
        }
        return nil
    }
    
    public func selectAll<T:NSManagedObject>(where predicate: NSPredicate,sortDescriptors: [NSSortDescriptor]? = nil) -> [T]? {
        if let context =  self.backgroundTheadFetchContext() {
            let fetchRequest = T.fetchRequest()
            fetchRequest.predicate = predicate
            if let sortDescriptors = sortDescriptors {
                fetchRequest.sortDescriptors = sortDescriptors
            }
            let results = try! context.fetch(fetchRequest) as! [T]
            return results
        }
        return nil
    }
    
    public func defaultDeleteContext() -> NSManagedObjectContext? {
        if let ayncSaveOrDeleteContext = self.ayncSaveOrDeleteContext {
            return ayncSaveOrDeleteContext
        }
        return nil
    }
    
    public func defaultSaveContext() -> NSManagedObjectContext? {
        if let ayncSaveOrDeleteContext = self.ayncSaveOrDeleteContext {
            return ayncSaveOrDeleteContext
        }
        return nil
    }
    
    public func defaultFetchContext() -> NSManagedObjectContext? {
        if let fetch = self.asyncDataFetchContext {
            return fetch
        }
        return nil
    }
    
    public func mainThreadContext() -> NSManagedObjectContext? {
        if let main = self.mainContext {
            return main
        }
        return nil
    }
    
    public func backgroundTheadSaveContext() -> NSManagedObjectContext? {
        if let ayncSaveOrDeleteContext = self.ayncSaveOrDeleteContext {
            return ayncSaveOrDeleteContext
        }
        return nil
    }
    
    public func backgroundTheadDeleteContext() -> NSManagedObjectContext? {
        if let ayncSaveOrDeleteContext = self.ayncSaveOrDeleteContext {
            return ayncSaveOrDeleteContext
        }
        return nil
    }
    
    public func backgroundTheadFetchContext() -> NSManagedObjectContext? {
        if let fetch = self.asyncDataFetchContext {
            return fetch
        }
        return nil
    }
    public func getNewBackgroundTheadContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private func createStore() throws {
        
        //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: self.storeName, withExtension:"momd") else {
            throw MRCoreDataError.creationError(message:"MRCoreDataError: Unable to Find Data Model '\(self.storeName).xcdatamodeld' in your project")
        }
        //The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            throw MRCoreDataError.creationError(message: "MRCoreDataError: Error initializing Data Model from '\(modelURL)'")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        guard let docURL = FileManager.default.urls(for: self.storeDirectory, in: .userDomainMask).last else {
            throw MRCoreDataError.creationError(message: "MRCoreDataError: Directory not found for store directory '\(self.storeDirectory)'")
        }
        
        let storeURL = docURL.appendingPathComponent("\(self.storeName).sqlite")
        
        if !FileManager.default.fileExists(atPath: storeURL.absoluteString) {
            do {
                let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            } catch {
                throw MRCoreDataError.creationError(message: error.localizedDescription)
            }
        }
        
        self.persistentStoreCoordinator = psc
        self.managedObjectModel =  mom
        
        ayncSaveOrDeleteContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        ayncSaveOrDeleteContext?.persistentStoreCoordinator = self.persistentStoreCoordinator
        ayncSaveOrDeleteContext?.automaticallyMergesChangesFromParent = true
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.mainContext?.parent = self.ayncSaveOrDeleteContext
        self.mainContext?.automaticallyMergesChangesFromParent = true
        
        asyncDataFetchContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        asyncDataFetchContext?.parent = self.mainContext
        asyncDataFetchContext?.automaticallyMergesChangesFromParent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(MRCoreDataStore.mainContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MRCoreDataStore.ayncSaveOrDeleteContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: ayncSaveOrDeleteContext)
    }
    
    //  open func saveContextAndWait(_ context: NSManagedObjectContext) {
    //        if context.parent === self.mainContext {
    //            saveAyncSaveOrDeleteContextAndWait(context)
    //            return
    //        }
    //        context.performAndWait {
    //            try! context.obtainPermanentIDs(for:context.insertedObjects.reversed())
    //            try! context.save()
    //        }
    //    }
    //  open func saveContext(_ context: NSManagedObjectContext) {
    //        if context.parent === self.mainContext {
    //            saveAyncSaveOrDeleteContext(context)
    //            return
    //        }
    //        context.perform() {
    //            try! context.obtainPermanentIDs(for:context.insertedObjects.reversed())
    //            try! context.save()
    //        }
    //    }
    //    open func saveAyncSaveOrDeleteContext(_ context: NSManagedObjectContext) {
    //        context.perform() {
    //            try! context.obtainPermanentIDs(for:context.insertedObjects.reversed())
    //            try! context.save()
    //            DispatchQueue.main.async() {
    //                self.saveContext(self.mainContext!)
    //            }
    //        }
    //    }
    //
    //    open func saveAyncSaveOrDeleteContextAndWait(_ context: NSManagedObjectContext) {
    //        context.performAndWait {
    //            try! context.obtainPermanentIDs(for:context.insertedObjects.reversed())
    //            try! context.save()
    //            DispatchQueue.main.async() {
    //                self.saveContextAndWait(self.mainContext!)
    //            }
    //        }
    //    }
    @objc private func ayncSaveOrDeleteContextDidSave(_ notification: Notification) {
        //        DispatchQueue.main.async() {
        //           //self.asyncDataFetchContext?.performAndWait {
        //            //try? self.mainContext?.save()
        //        }
        
        //        if let userInfo = notification.userInfo {
        //            for item in userInfo {
        //              // print(item.value)
        //                if let set = item.value as? NSSet, let object = set.allObjects.first as? NSManagedObject {
        //                    //self.ayncSaveOrDeleteContext?.
        //
        //                }
        //            }
        //        }
        
        self.asyncDataFetchContext?.refreshAllObjects()
        self.mainContext?.refreshAllObjects()
        
        
        
        //        DispatchQueue.main.async() {
        //        self.asyncDataFetchContext?.performAndWait {
        //        try? self.asyncDataFetchContext?.obtainPermanentIDs(for:(self.asyncDataFetchContext?.insertedObjects.reversed())!)
        //        try? self.asyncDataFetchContext?.save()
        //        }
        //        }
    }
    
    @objc private func mainContextDidSave(_ notification: Notification) {
        self.asyncDataFetchContext?.refreshAllObjects()
    }
    
}

