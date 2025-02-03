//
//  CoreDataManager.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//





import CoreData


class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MovieModels")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
            
            // Enable constraints
//            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
}
