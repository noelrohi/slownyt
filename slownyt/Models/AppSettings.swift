import Foundation
import SwiftUI

enum RefreshCadence: Int, CaseIterable, Sendable {
    case manual = 0
    case oneMinute = 60
    case twoMinutes = 120
    case fiveMinutes = 300
    case fifteenMinutes = 900

    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .oneMinute: return "1 min"
        case .twoMinutes: return "2 min"
        case .fiveMinutes: return "5 min"
        case .fifteenMinutes: return "15 min"
        }
    }

    var seconds: TimeInterval? {
        self == .manual ? nil : TimeInterval(rawValue)
    }
}

@Observable
final class AppSettings {
    static let shared = AppSettings()

    var refreshCadence: RefreshCadence {
        didSet {
            UserDefaults.standard.set(refreshCadence.rawValue, forKey: "refreshCadence")
        }
    }

    private init() {
        let storedValue = UserDefaults.standard.integer(forKey: "refreshCadence")
        self.refreshCadence = RefreshCadence(rawValue: storedValue) ?? .fiveMinutes
    }
}
