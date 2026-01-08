import Foundation

nonisolated final class PingService: NetworkDiagnosticService {
    let testId = "ping"
    let testName = "Ping (ICMP)"
    private let host = "8.8.8.8"

    func runDiagnostic() async -> DiagnosticResult {
        // Use a timeout task to prevent hanging
        do {
            return try await withThrowingTaskGroup(of: DiagnosticResult.self) { group in
                group.addTask {
                    try await self.runPing()
                }

                group.addTask {
                    try await Task.sleep(for: .seconds(8))
                    throw CancellationError()
                }

                // Return first completed result
                if let result = try await group.next() {
                    group.cancelAll()
                    return result
                }

                throw CancellationError()
            }
        } catch {
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: .bad,
                details: "Ping timed out or blocked by sandbox"
            )
        }
    }

    private func runPing() async throws -> DiagnosticResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", "-t", "3", host]  // 1 ping, 3 sec timeout

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let start = ContinuousClock.now

        try process.run()
        process.waitUntilExit()

        let elapsed = start.duration(to: .now)

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: .bad,
                details: "Ping failed: \(output.prefix(50))"
            )
        }

        // Parse ping time from output
        let latencyMs = parseLatency(from: output)

        let status: DiagnosticStatus
        if let latency = latencyMs {
            if latency < 50 {
                status = .good
            } else if latency < 150 {
                status = .warning
            } else {
                status = .bad
            }
        } else {
            // Use elapsed time as fallback
            let elapsedMs = Double(elapsed.components.seconds) * 1000 +
                           Double(elapsed.components.attoseconds) / 1_000_000_000_000_000
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: elapsedMs < 150 ? .good : .warning,
                latencyMs: elapsedMs,
                details: "Ping to \(host): \(Int(elapsedMs))ms"
            )
        }

        return DiagnosticResult(
            id: testId,
            testName: testName,
            status: status,
            latencyMs: latencyMs,
            details: "Ping to \(host): \(Int(latencyMs!))ms"
        )
    }

    private func parseLatency(from output: String) -> Double? {
        // Look for: time=14.225 ms
        let pattern = #"time[=<]([\d.]+)\s*ms"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)),
              let timeRange = Range(match.range(at: 1), in: output) else {
            return nil
        }
        return Double(output[timeRange])
    }
}
