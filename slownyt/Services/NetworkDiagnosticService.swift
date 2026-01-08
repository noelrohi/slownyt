import Foundation

protocol NetworkDiagnosticService: Sendable {
    var testId: String { get }
    var testName: String { get }
    func runDiagnostic() async -> DiagnosticResult
}
