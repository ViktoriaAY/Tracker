import UIKit

// MARK: - Tracker Model

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: TrackerSchedule?
}

// MARK: - TrackerSchedule Model

struct TrackerSchedule {
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
}

// MARK: - TrackerSchedule Extension (Weekday Verification)

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

// MARK: - TrackerSchedule Extension (Localization Logic)

extension TrackerSchedule {
    func getShortString() -> String {
        if monday && tuesday && wednesday && thursday && friday && saturday && sunday {
            return "every_day".localized
        }
        
        var days: [String] = []
        if monday { days.append("monday_short".localized) }
        if tuesday { days.append("tuesday_short".localized) }
        if wednesday { days.append("wednesday_short".localized) }
        if thursday { days.append("thursday_short".localized) }
        if friday { days.append("friday_short".localized) }
        if saturday { days.append("saturday_short".localized) }
        if sunday { days.append("sunday_short".localized) }
        
        if days.isEmpty {
            return ""
        }
        
        return days.joined(separator: ", ")
    }
}
