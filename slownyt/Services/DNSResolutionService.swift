import Foundation

nonisolated final class DNSResolutionService: NetworkDiagnosticService {
    let testId = "dns"
    let testName = "DNS Resolution"
    private let hostname = "registry.npmjs.org"

    func runDiagnostic() async -> DiagnosticResult {
        let start = ContinuousClock.now

        let host = CFHostCreateWithName(nil, hostname as CFString).takeRetainedValue()

        var streamError = CFStreamError()
        let success = CFHostStartInfoResolution(host, .addresses, &streamError)

        let elapsed = start.duration(to: .now)
        let latencyMs = Double(elapsed.components.attoseconds) / 1_000_000_000_000_000 +
                       Double(elapsed.components.seconds) * 1000

        guard success else {
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: .bad,
                latencyMs: latencyMs,
                details: "Failed to resolve \(hostname)"
            )
        }

        var resolved = DarwinBoolean(false)
        guard let addresses = CFHostGetAddressing(host, &resolved)?.takeUnretainedValue() as? [Data],
              resolved.boolValue,
              !addresses.isEmpty else {
            return DiagnosticResult(
                id: testId,
                testName: testName,
                status: .bad,
                latencyMs: latencyMs,
                details: "No addresses found for \(hostname)"
            )
        }

        let status: DiagnosticStatus
        if latencyMs < DiagnosticThresholds.DNS.goodMs {
            status = .good
        } else if latencyMs < DiagnosticThresholds.DNS.warningMs {
            status = .warning
        } else {
            status = .bad
        }

        return DiagnosticResult(
            id: testId,
            testName: testName,
            status: status,
            latencyMs: latencyMs,
            details: "Resolved \(hostname) in \(Int(latencyMs))ms"
        )
    }
}
