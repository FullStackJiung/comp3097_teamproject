import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showResetAlert = false
    @State private var showShareSheet = false
    @State private var exportText = ""

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
                            exportText = generateExportText()
                            showShareSheet = true
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: exportText)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func generateExportText() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: today)

        var lines: [String] = []
        lines.append("=== Habit Tracker Summary ===")
        lines.append("Exported: \(dateString)")
        lines.append("")

        let activeHabits = store.activeHabits
        let archivedHabits = store.habits.filter { $0.isArchived }

        lines.append("Active Habits: \(activeHabits.count)")
        lines.append("Archived Habits: \(archivedHabits.count)")
        lines.append("")

        if !activeHabits.isEmpty {
            lines.append("--- Active Habits ---")
            for habit in activeHabits {
                let weekCompletions = store.getWeekCompletions(habitId: habit.id, weekStart: today)
                let streak = store.getStreak(habitId: habit.id)
                let rate = habit.goalPerWeek > 0
                    ? Int(min(Double(weekCompletions) / Double(habit.goalPerWeek), 1.0) * 100)
                    : 0
                lines.append("• \(habit.title)")
                lines.append("  Goal: \(habit.goalPerWeek)x/week")
                lines.append("  This week: \(weekCompletions)/\(habit.goalPerWeek) (\(rate)%)")
                lines.append("  Streak: \(streak) day(s)")
                lines.append("")
            }
        }

        if !archivedHabits.isEmpty {
            lines.append("--- Archived Habits ---")
            for habit in archivedHabits {
                lines.append("• \(habit.title) (archived)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
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

private struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(HabitStore())
    }
}
