import Foundation
import AppMetricaCore

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    private init() {}
    
    func report(event: AnalyticsEvent, screen: AnalyticsScreen = .main, item: AnalyticsItem? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        
        if let item = item, event == .click {
            params["item"] = item.rawValue
        }
        
        print("📊 [Analytics] Отправлено событие: \(params)")
        
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("❌ [Analytics] Ошибка отправки события: \(error.localizedDescription)")
        }
    }
}

