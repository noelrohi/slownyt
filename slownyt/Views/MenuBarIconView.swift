import SwiftUI

struct MenuBarIconView: View {
    let status: DiagnosticStatus

    var body: some View {
        Image(systemName: iconName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(status.color, .primary)
    }

    private var iconName: String {
        switch status {
        case .good:
            return "network"
        case .warning:
            return "network.badge.shield.half.filled"
        case .bad:
            return "network.slash"
        case .unknown:
            return "network"
        case .running:
            return "network"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MenuBarIconView(status: .good)
        MenuBarIconView(status: .warning)
        MenuBarIconView(status: .bad)
        MenuBarIconView(status: .unknown)
        MenuBarIconView(status: .running)
    }
    .padding()
}
