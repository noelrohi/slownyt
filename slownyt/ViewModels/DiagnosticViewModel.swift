import Foundation
import Observation

@Observable
final class DiagnosticViewModel {
    private(set) var results: [DiagnosticResult] = []
    private(set) var isRunning = false
    private(set) var overallStatus: DiagnosticStatus = .unknown
    private(set) var lastRunDate: Date?

    private let services: [any NetworkDiagnosticService] = [
        PingService(),
        ConnectivityService(),
        DNSResolutionService(),
        NPMRegistryLatencyService(),
        DownloadSpeedService()
    ]

    private var refreshTask: Task<Void, Never>?
    private let settings = AppSettings.shared

    init() {
        setupAutoRefresh()
    }

    func runAllDiagnostics() async {
        guard !isRunning else { return }

        isRunning = true

        // Initialize with running state
        results = services.map { service in
            DiagnosticResult.running(id: service.testId, testName: service.testName)
        }

        // Run each diagnostic sequentially
        for (index, service) in services.enumerated() {
            let result = await service.runDiagnostic()
            results[index] = result
        }

        overallStatus = calculateOverallStatus()
        lastRunDate = Date()
        isRunning = false
    }

    func setupAutoRefresh() {
        refreshTask?.cancel()

        guard let interval = settings.refreshCadence.seconds else {
            return
        }

        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }
                await self?.runAllDiagnostics()
            }
        }
    }

    private func calculateOverallStatus() -> DiagnosticStatus {
        if results.isEmpty { return .unknown }
        if results.contains(where: { $0.status == .bad }) { return .bad }
        if results.contains(where: { $0.status == .warning }) { return .warning }
        if results.contains(where: { $0.status == .running }) { return .running }
        return .good
    }
}
