import UIKit
import CoreData

// MARK: - TrackerStoreDelegate Protocol

protocol TrackerStoreDelegate: AnyObject {
    func storeDidChangeTrackers()
}

// MARK: - TrackerStore Class

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: TrackerStoreDelegate?
    
    private var context: NSManagedObjectContext {
        return CoreDataStack.shared.context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)]
        
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
    
    var trackers: [Tracker] {
        if fetchedResultsController.fetchedObjects == nil {
            try? fetchedResultsController.performFetch()
        }
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { tracker(from: $0) }
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    // MARK: - Private Methods
    
    private func hexString(from color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    private func color(from hex: String) -> UIColor {
        var rgb: UInt64 = 0
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    private func scheduleString(from schedule: TrackerSchedule) -> String {
        var days: [String] = []
        if schedule.monday { days.append("1") }
        if schedule.tuesday { days.append("2") }
        if schedule.wednesday { days.append("3") }
        if schedule.thursday { days.append("4") }
        if schedule.friday { days.append("5") }
        if schedule.saturday { days.append("6") }
        if schedule.sunday { days.append("7") }
        return days.joined(separator: ",")
    }
    
    private func schedule(from string: String) -> TrackerSchedule {
        let components = string.components(separatedBy: ",")
        return TrackerSchedule(
            monday: components.contains("1"),
            tuesday: components.contains("2"),
            wednesday: components.contains("3"),
            thursday: components.contains("4"),
            friday: components.contains("5"),
            saturday: components.contains("6"),
            sunday: components.contains("7")
        )
    }
    
    // MARK: - Public Methods
    
    func createTracker(_ tracker: Tracker, categoryCoreData: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = hexString(from: tracker.color)
        
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = scheduleString(from: schedule)
        } else {
            trackerCoreData.schedule = ""
        }
        
        trackerCoreData.category = categoryCoreData
        try context.save()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let emoji = trackerCoreData.emoji,
            let colorHex = trackerCoreData.colorHex,
            let scheduleStr = trackerCoreData.schedule
        else { return nil }
        
        return Tracker(
            id: id,
            title: title,
            color: color(from: colorHex),
            emoji: emoji,
            schedule: schedule(from: scheduleStr)
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidChangeTrackers()
    }
}
