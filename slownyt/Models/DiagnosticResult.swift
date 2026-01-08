import Foundation

struct DiagnosticResult: Sendable, Identifiable {
    let id: String
    let testName: String
    let status: DiagnosticStatus
    let latencyMs: Double?
    let speedMbps: Double?
    let details: String
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        testName: String,
        status: DiagnosticStatus,
        latencyMs: Double? = nil,
        speedMbps: Double? = nil,
        details: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.testName = testName
        self.status = status
        self.latencyMs = latencyMs
        self.speedMbps = speedMbps
        self.details = details
        self.timestamp = timestamp
    }

    static func running(id: String, testName: String) -> DiagnosticResult {
        DiagnosticResult(
            id: id,
            testName: testName,
            status: .running,
            details: "Running..."
        )
    }

    static func error(id: String, testName: String, error: Error) -> DiagnosticResult {
        DiagnosticResult(
            id: id,
            testName: testName,
            status: .bad,
            details: "Error: \(error.localizedDescription)"
        )
    }
}
