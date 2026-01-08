import Foundation

nonisolated final class ConnectivityService: NetworkDiagnosticService {
    let testId = "connectivity"
    let testName = "Internet Connectivity"

    func runDiagnostic() async -> DiagnosticResult {
        guard let url = URL(string: "https://www.google.com") else {
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: .bad,
                details: "Invalid URL"
            )
        }

        let start = ContinuousClock.now

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10

            let (_, response) = try await URLSession.shared.data(for: request)

            let elapsed = start.duration(to: .now)
            let latencyMs = Double(elapsed.components.attoseconds) / 1_000_000_000_000_000 +
                           Double(elapsed.components.seconds) * 1000

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...399).contains(httpResponse.statusCode) else {
                return DiagnosticResult(
                    id: testId,
                    testName: testName,
                    status: .bad,
                    latencyMs: latencyMs,
                    details: "Failed to reach internet"
                )
            }

            let status: DiagnosticStatus
            if latencyMs < DiagnosticThresholds.Connectivity.goodMs {
                status = .good
            } else if latencyMs < DiagnosticThresholds.Connectivity.warningMs {
                status = .warning
            } else {
                status = .bad
            }

            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: status,
                latencyMs: latencyMs,
                details: "Connected in \(Int(latencyMs))ms"
            )
        } catch {
            return DiagnosticResult.error(id: testId, testName: testName, error: error)
        }
    }
}
