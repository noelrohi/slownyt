import SwiftUI

struct DiagnosticPopoverView: View {
    @Bindable var viewModel: DiagnosticViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("NPM Diagnostic")
                    .font(.headline)

                Spacer()

                if let lastRun = viewModel.lastRunDate {
                    Text(lastRun, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Results List
            if viewModel.results.isEmpty {
                Text("Running diagnostics...")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.results) { result in
                    DiagnosticResultRow(result: result)
                }
            }

            Divider()

            // Actions
            HStack {
                Button {
                    Task {
                        await viewModel.runAllDiagnostics()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isRunning)

                Spacer()

                Button {
                    openWindow(id: "settings")
                } label: {
                    Image(systemName: "gear")
                }
                .buttonStyle(.borderless)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 320)
        .task {
            if viewModel.results.isEmpty {
                await viewModel.runAllDiagnostics()
            }
        }
    }
}

#Preview {
    DiagnosticPopoverView(viewModel: DiagnosticViewModel())
}
