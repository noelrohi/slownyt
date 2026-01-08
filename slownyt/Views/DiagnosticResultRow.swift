import SwiftUI

struct DiagnosticResultRow: View {
    let result: DiagnosticResult

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(result.status.color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(result.testName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    if result.status == .running {
                        ProgressView()
                            .controlSize(.small)
                    } else if let latency = result.latencyMs {
                        Text("\(Int(latency))ms")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    } else if let speed = result.speedMbps {
                        Text(String(format: "%.1f Mbps", speed))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Text(result.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 8) {
        DiagnosticResultRow(result: DiagnosticResult(
            id: "1",
            testName: "Internet Connectivity",
            status: .good,
            latencyMs: 45,
            details: "Connected in 45ms"
        ))

        DiagnosticResultRow(result: DiagnosticResult(
            id: "2",
            testName: "DNS Resolution",
            status: .warning,
            latencyMs: 150,
            details: "Resolved registry.npmjs.org in 150ms"
        ))

        DiagnosticResultRow(result: DiagnosticResult(
            id: "3",
            testName: "NPM Download Speed",
            status: .good,
            speedMbps: 25.5,
            details: "25.5 Mbps (530 KB in 0.17s)"
        ))

        DiagnosticResultRow(result: DiagnosticResult.running(id: "4", testName: "Running Test"))
    }
    .padding()
    .frame(width: 300)
}
