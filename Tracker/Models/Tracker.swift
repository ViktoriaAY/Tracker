import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: TrackerSchedule?
}

struct TrackerSchedule {
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
}

extension TrackerSchedule {
    func isScheduled(on weekdayIndex: Int) -> Bool {
        switch weekdayIndex {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return false
        }
    }
}

extension TrackerSchedule {
    func getShortString() -> String {
        if monday && tuesday && wednesday && thursday && friday && saturday && sunday {
            return "Каждый день"
        }
        
        var days: [String] = []
        if monday { days.append("Пн") }
        if tuesday { days.append("Вт") }
        if wednesday { days.append("Ср") }
        if thursday { days.append("Чт") }
        if friday { days.append("Пт") }
        if saturday { days.append("Сб") }
        if sunday { days.append("Вс") }
        
        if days.isEmpty {
            return ""
        }
        
        return days.joined(separator: ", ")
    }
}
