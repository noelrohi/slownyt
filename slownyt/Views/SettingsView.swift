import SwiftUI

struct SettingsView: View {
    @Bindable private var settings = AppSettings.shared
    var onCadenceChanged: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Refresh cadence")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Refresh cadence", selection: $settings.refreshCadence) {
                    ForEach(RefreshCadence.allCases, id: \.self) { cadence in
                        Text(cadence.displayName).tag(cadence)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.refreshCadence) {
                    onCadenceChanged?()
                }
            }

            Spacer()

            HStack {
                Spacer()
                Text("slownyt")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding(24)
        .frame(width: 400, height: 200)
    }
}

#Preview {
    SettingsView()
}
