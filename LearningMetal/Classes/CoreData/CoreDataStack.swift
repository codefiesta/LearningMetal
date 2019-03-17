//
//  CoreDataStack.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    // The persistent container for the application
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LearningMetal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Saves the context
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
