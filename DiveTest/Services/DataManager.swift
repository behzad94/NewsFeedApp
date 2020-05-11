//
//  DataManager.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import Foundation
import CoreData

class DataManager {
    private init() {}
    let moduleName = "DiveTest"
    static let shared = DataManager()
    lazy var context = persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: moduleName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func storeFeed(rss: RSSItem) {
        let entity = NSEntityDescription.entity(forEntityName: "Feed", in: context)
        let managedObj = NSManagedObject(entity: entity!, insertInto: context)
        managedObj.setValue(rss.title, forKey: "title")
        managedObj.setValue(rss.pubdate, forKey: "pubdate")
        managedObj.setValue(rss.link, forKey: "link")
        managedObj.setValue(rss.imgUrl, forKey: "imgUrl")
        managedObj.setValue(rss.postId, forKey: "postId")
        saveContext()
    }

    
    func storeObjectToBookmarks(feed: Feed) {
        guard let id = feed.postId else { return }
        let predicate = NSPredicate(format: "id = %@", id)
        let result = fetch(Bookmarks.self, key: nil, ascending: nil, predicate: predicate)
        if !result.isEmpty {
            for object in result {
                context.delete(object)
            }
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "Bookmarks", in: context)
            let manageObject = NSManagedObject(entity: entity!, insertInto: context)
            manageObject.setValue(feed.postId, forKey: "id")
            manageObject.setValue(String(describing: Date()), forKey: "createdAt")
            manageObject.setValue(feed.imgUrl, forKey: "imgUrl")
            manageObject.setValue(feed.link, forKey: "link")
            manageObject.setValue(feed.title, forKey: "title")
        }
        saveContext()
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, key: String?, ascending: Bool?, predicate: NSPredicate?) -> [T] {
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        if key != nil && ascending != nil {
            let sortDescriptor = NSSortDescriptor(key: key, ascending: ascending!)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch {
            print("error fetch request")
            return [T]()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
    
    func deleteDataByPredicate<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate?) {
        let entityName = String(describing: entity)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
        saveContext()
    }
    
    func deleteAllData<T: NSManagedObject>(_ entity: T.Type) {
        let entityName = String(describing: entity)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
        saveContext()
    }
    
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}
