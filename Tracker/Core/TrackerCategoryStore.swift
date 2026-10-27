import Foundation
import CoreData

// MARK: - TrackerCategoryStoreDelegate Protocol

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidChangeCategories()
}

// MARK: - TrackerCategoryStore Class

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategory] {
        if fetchedResultsController.fetchedObjects == nil {
            try? fetchedResultsController.performFetch()
        }
        
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
            let trackers = trackersCoreData.compactMap { trackerStore.tracker(from: $0) }
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    private lazy var context: NSManagedObjectContext = {
        CoreDataStack.shared.context
    }()
    
    private lazy var trackerStore = TrackerStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Ошибка performFetch в TrackerCategoryStore: \(error)")
        }
        return controller
    }()
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    func addCategory(title: String) throws {
        if try fetchCategoryCoreData(with: title) != nil { return }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        try context.save()
    }
    
    func fetchCategoryCoreData(with title: String) throws -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChangeCategories()
    }
}
