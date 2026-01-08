import Foundation

enum DiagnosticThresholds {
    enum Connectivity {
        static let goodMs: Double = 100
        static let warningMs: Double = 500
    }

    enum DNS {
        static let goodMs: Double = 50
        static let warningMs: Double = 200
    }

    enum Registry {
        static let goodMs: Double = 100
        static let warningMs: Double = 300
    }

    enum Download {
        static let goodMbps: Double = 10
        static let warningMbps: Double = 1
    }
}
