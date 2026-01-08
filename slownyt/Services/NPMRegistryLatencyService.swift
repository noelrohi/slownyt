import Foundation

nonisolated final class NPMRegistryLatencyService: NetworkDiagnosticService {
    let testId = "npm-latency"
    let testName = "NPM Registry Latency"

    func runDiagnostic() async -> DiagnosticResult {
        guard let url = URL(string: "https://registry.npmjs.org/lodash") else {
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
            request.timeoutInterval = 15

            let (_, response) = try await URLSession.shared.data(for: request)

            let elapsed = start.duration(to: .now)
            let latencyMs = Double(elapsed.components.attoseconds) / 1_000_000_000_000_000 +
                           Double(elapsed.components.seconds) * 1000

            guard let httpResponse = response as? HTTPURLResponse else {
                return DiagnosticResult(
                    id: testId,
                    testName: testName,
                    status: .bad,
                    latencyMs: latencyMs,
                    details: "Invalid response from registry"
                )
            }

            let serverInfo = httpResponse.value(forHTTPHeaderField: "X-Served-By") ?? "Unknown"

            guard (200...399).contains(httpResponse.statusCode) else {
                return DiagnosticResult(
                    id: testId,
                    testName: testName,
                    status: .bad,
                    latencyMs: latencyMs,
                    details: "Registry returned \(httpResponse.statusCode)"
                )
            }

            let status: DiagnosticStatus
            if latencyMs < DiagnosticThresholds.Registry.goodMs {
                status = .good
            } else if latencyMs < DiagnosticThresholds.Registry.warningMs {
                status = .warning
            } else {
                status = .bad
            }

            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: status,
                latencyMs: latencyMs,
                details: "Registry response: \(Int(latencyMs))ms\nServer: \(serverInfo)"
            )
        } catch {
            return DiagnosticResult.error(id: testId, testName: testName, error: error)
        }
    }
}
