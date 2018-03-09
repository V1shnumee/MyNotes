//
//  Notes.swift
//  MyNotes
//
//  Created by Vishnuvarthan Palani on 3/7/18.
//  Copyright © 2018 Vishnuvarthan Palani. All rights reserved.
//

import Foundation
import CoreData

open class ModelHandler: NSObject{
    
    var dataContext : NSManagedObjectContext?
    public static let shared : ModelHandler = {
        let instance = ModelHandler()
        return instance
    }()
    
    fileprivate func setContext(context : NSManagedObjectContext?) {
        guard let objContext = context else {
            return
        }
        dataContext = objContext
    }
    
    fileprivate func saveContext() {
        do {
            try dataContext?.save()
        } catch  {
            print("Core Data Error on Save ---> \(error))")
        }
    }
    
    fileprivate func fetchResults(entityName : String , predicate : NSPredicate? = nil, sortBy: String? = nil) -> Array<Any> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        if let sortOrder = sortBy {
            let sorter = NSSortDescriptor(key:sortOrder , ascending:true)
            fetchRequest.sortDescriptors = [sorter]
        }
        var result : Array<Any>
        do{
            result = try dataContext?.fetch(fetchRequest) ?? []
        }
        catch{
            print("Core Data Error on Fetch --->\(error)")
            return []
        }
        return result
    }
    
    fileprivate func updateEntity(entityName : String , predicate : NSPredicate? = nil , newValue : [String:Any]) {
        
        let updateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        updateRequest.predicate = predicate
        
        do {
            let result = try dataContext?.fetch(updateRequest)
            let entity = result?.first
            for (key,value) in newValue {
                (entity as AnyObject).setValue(value, forKey:key)
            }
            saveContext()
        } catch {
            print("Core Data Error on update ----->  \(error)")
        }
    }
}


extension ModelHandler {
    
  func getSavedNotes() -> [Notes]{
    return ModelHandler.shared.fetchResults(entityName: "Notes", predicate: nil, sortBy: "lastModified") as! [Notes]
    }
    
    
    func updateNotes(note : Notes) {
        let predicateToUpdate = NSPredicate(format: "id = \(String(describing: note.id))")
        
        ModelHandler.shared.updateEntity(entityName: "Notes", predicate: predicateToUpdate, newValue: ["lastModified" :!(note.lastModified != nil)])
    }
}

