import Foundation

nonisolated final class DownloadSpeedService: NetworkDiagnosticService {
    let testId = "download-speed"
    let testName = "NPM Download Speed"

    func runDiagnostic() async -> DiagnosticResult {
        // Download lodash tarball (~530KB) to test download speed
        guard let url = URL(string: "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz") else {
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
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)

            let elapsed = start.duration(to: .now)
            let elapsedSeconds = Double(elapsed.components.seconds) +
                                Double(elapsed.components.attoseconds) / 1_000_000_000_000_000_000

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...399).contains(httpResponse.statusCode) else {
                return DiagnosticResult(
                    id: testId,
                    testName: testName,
                    status: .bad,
                    details: "Failed to download package"
                )
            }

            let bytesDownloaded = Double(data.count)
            let speedMbps = (bytesDownloaded * 8) / (max(elapsedSeconds, 0.001) * 1_000_000)

            let status: DiagnosticStatus
            if speedMbps >= DiagnosticThresholds.Download.goodMbps {
                status = .good
            } else if speedMbps >= DiagnosticThresholds.Download.warningMbps {
                status = .warning
            } else {
                status = .bad
            }

            let sizeKB = bytesDownloaded / 1024

            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: status,
                speedMbps: speedMbps,
                details: String(format: "%.1f Mbps (%.0f KB in %.2fs)", speedMbps, sizeKB, elapsedSeconds)
            )
        } catch {
            return DiagnosticResult.error(id: testId, testName: testName, error: error)
        }
    }
}
