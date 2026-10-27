import Foundation
import CoreData
import OSLog

// MARK: - CoreDataStack Class

final class CoreDataStack {
    
    // MARK: - Static Properties
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    private let logger = Logger(category: "CoreDataStack")
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.main.url(forResource: "Tracker", withExtension: "momd") else {
            logger.fault("❌ Не удалось найти файл модели Tracker.xcdatamodeld в Bundle приложения")
            assertionFailure("Не удалось найти файл модели Tracker.xcdatamodeld")
            return NSPersistentContainer(name: "Tracker")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            logger.fault("❌ Не удалось инициализировать NSManagedObjectModel по адресу: \(modelURL, privacy: .public)")
            assertionFailure("Не удалось инициализировать NSManagedObjectModel")
            return NSPersistentContainer(name: "Tracker")
        }
        
        let container = NSPersistentContainer(name: "Tracker", managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                self?.logger.fault("❌ Не удалось загрузить хранилище Core Data: \(error.localizedDescription, privacy: .public), \(error.userInfo, privacy: .public)")
                assertionFailure("Не удалось загрузить хранилище Core Data: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                logger.info("💾 Данные успешно сохранены в Core Data!")
            } catch {
                let nserror = error as NSError
                logger.error("❌ Ошибка при сохранении контекста: \(nserror.localizedDescription, privacy: .public), \(nserror.userInfo, privacy: .public)")
            }
        }
    }
}

// MARK: - Logger Extension

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.tracker"
    
    init(category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
}
