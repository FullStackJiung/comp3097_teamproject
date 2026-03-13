import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEdit = false

    let habitId: UUID

    var body: some View {
        if let habit = store.habits.first(where: { $0.id == habitId }) {
            let today = Date()
            let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt
            let weekCompletions = store.getWeekCompletions(habitId: habit.id, weekStart: today)
            let completionRate = habit.goalPerWeek > 0
                ? min(Double(weekCompletions) / Double(habit.goalPerWeek), 1.0)
                : 0
            let streak = store.getStreak(habitId: habit.id)

            ScrollView {
                VStack(spacing: 16) {
                    habitCard(habit: habit)

                    statsGrid(
                        completionRate: completionRate,
                        weekCompletions: weekCompletions,
                        streak: streak,
                        goalPerWeek: habit.goalPerWeek
                    )

                    historySection(habit: habit, today: today)
                }
                .padding(16)
            }
            .background(background)
            .navigationTitle("Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") { showEdit = true }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(habit.isArchived ? "Unarchive" : "Archive") {
                        if habit.isArchived {
                            store.unarchiveHabit(id: habit.id)
                        } else {
                            store.archiveHabit(id: habit.id)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEdit) {
                HabitFormView(habit: habit, onComplete: { showEdit = false })
                    .environmentObject(store)
            }
        } else {
            VStack {
                Text("Habit not found")
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func habitCard(habit: Habit) -> some View {
        VStack(spacing: 12) {
            Image(systemName: habit.symbolName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(Color(hex: habit.colorHex))
            Text(habit.title)
                .font(.title2.bold())
                .foregroundColor(AppColors.textPrimary)
            Text("Goal: \(habit.goalPerWeek) times per week")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: habit.colorHex).opacity(0.15))
        )
    }

    private func statsGrid(
        completionRate: Double,
        weekCompletions: Int,
        streak: Int,
        goalPerWeek: Int
    ) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatsCardView(
                title: "Completion",
                value: "\(Int(completionRate * 100))%",
                subtitle: "This week",
                colorHex: "A8D8EA"
            )
            StatsCardView(
                title: "Week Total",
                value: "\(weekCompletions)",
                subtitle: "Completions",
                colorHex: "A8D8A8"
            )
            StatsCardView(
                title: "Streak",
                value: "\(streak)",
                subtitle: "Days",
                colorHex: "FFD4A3"
            )
            StatsCardView(
                title: "Goal",
                value: "\(weekCompletions)/\(max(goalPerWeek, 1))",
                subtitle: "This week",
                colorHex: "FFB5C2"
            )
        }
    }

    private func historySection(habit: Habit, today: Date) -> some View {
        let days = (0..<14).map { DateUtils.addDays(today, -$0) }.reversed()
        let cardColor = colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface

        return VStack(alignment: .leading, spacing: 12) {
            Text("Last 14 Days")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(Array(days), id: \.self) { date in
                let completed = store.isCompletedOnDate(habitId: habit.id, date: date)

                Button(action: { store.toggleCompletion(habitId: habit.id, date: date) }) {
                    HStack(spacing: 12) {
                        Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(completed ? AppColors.accent : AppColors.textSecondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(DateUtils.shortLabel(date))
                                .font(.subheadline.bold())
                                .foregroundColor(AppColors.textPrimary)
                            Text(completed ? "Completed" : "Not completed")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(cardColor)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    let store = HabitStore()
    return NavigationStack {
        HabitDetailView(habitId: store.habits.first?.id ?? UUID())
            .environmentObject(store)
    }
}
