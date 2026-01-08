import SwiftUI

enum DiagnosticStatus: String, Sendable, CaseIterable {
    case good
    case warning
    case bad
    case unknown
    case running

    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .orange
        case .bad: return .red
        case .unknown: return .gray
        case .running: return .blue
        }
    }

    var iconName: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .bad: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        case .running: return "circle.dotted"
        }
    }
}
