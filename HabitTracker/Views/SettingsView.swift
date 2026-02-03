import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showResetAlert = false
    @State private var showExportAlert = false

    var body: some View {
        let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt

        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                List {
                    Section("Appearance") {
                        Toggle("Dark Mode", isOn: $store.isDarkMode)
                            .tint(AppColors.accent)
                    }

                    Section("Data") {
                        Button("Export Summary") {
                            showExportAlert = true
                        }
                        .foregroundColor(AppColors.accent)

                        Button("Reset All Data") {
                            showResetAlert = true
                        }
                        .foregroundColor(.red)
                    }

                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        HStack {
                            Text("Built with")
                            Spacer()
                            Text("SwiftUI")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAllData()
            }
        } message: {
            Text("This will delete all habits and records.")
        }
        .alert("Export not available", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Export will be added in a future update.")
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.title.bold())
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(HabitStore())
    }
}
