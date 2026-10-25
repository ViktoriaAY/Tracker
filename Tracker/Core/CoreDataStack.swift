import Foundation
import CoreData

// MARK: - CoreDataStack Class

final class CoreDataStack {
    
    // MARK: - Static Properties
    
    static let shared = CoreDataStack()
    
    // MARK: - Public Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.main.url(forResource: "Tracker", withExtension: "momd") else {
            fatalError("❌ Ошибка: Не удалось найти файл модели Tracker.xcdatamodeld в Bundle приложения")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ Ошибка: Не удалось инициализировать NSManagedObjectModel по адресу: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: "Tracker", managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("❌ Не удалось загрузить хранилище Core Data: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Данные успешно сохранены в Core Data!")
            } catch {
                let nserror = error as NSError
                print("Ошибка при сохранении контекста: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
