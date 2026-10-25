import Foundation
import CoreData

// MARK: - TrackerRecordStoreDelegate Protocol

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidChangeRecords()
}

// MARK: - TrackerRecordStore Class

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private var context: NSManagedObjectContext {
        return CoreDataStack.shared.context
    }

        
        private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
            let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
            
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            controller.delegate = self
            return controller
        }()
        
        // MARK: - Public Properties
        
        var records: [TrackerRecord] {
            if fetchedResultsController.fetchedObjects == nil {
                try? fetchedResultsController.performFetch()
            }
            guard let objects = fetchedResultsController.fetchedObjects else { return [] }
            return objects.compactMap {
                guard let id = $0.id, let date = $0.date else { return nil }
                return TrackerRecord(id: id, date: date)
            }
        }
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    func add(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.id
        recordCoreData.date = record.date
        
        try context.save()
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            record.id as CVarArg,
            record.date as CVarArg
        )
        
        if let results = try? context.fetch(request) {
            for object in results {
                context.delete(object)
            }
            try context.save()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChangeRecords()
    }
}
