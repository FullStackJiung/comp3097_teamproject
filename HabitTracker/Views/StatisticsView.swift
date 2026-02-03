import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var weekStart = DateUtils.startOfWeek(Date())

    var body: some View {
        let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt
        let activeHabits = store.activeHabits
        let stats = activeHabits.map { habit in
            HabitStats(
                habit: habit,
                completions: store.getWeekCompletions(habitId: habit.id, weekStart: weekStart),
                streak: store.getStreak(habitId: habit.id)
            )
        }

        let totalCompletions = stats.reduce(0) { $0 + $1.completions }
        let averageRate = stats.isEmpty ? 0 : stats.reduce(0.0) { $0 + $1.completionRate } / Double(stats.count)
        let bestHabit = stats.max(by: { $0.completionRate < $1.completionRate })
        let bestStreak = stats.map { $0.streak }.max() ?? 0
        let rankedHabits = stats.sorted(by: { $0.completions > $1.completions })

        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if activeHabits.isEmpty {
                    EmptyStateView(
                        title: "No data yet",
                        message: "Track habits to see statistics here.",
                        systemImage: "chart.bar"
                    )
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            weekPicker

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                StatsCardView(
                                    title: "Total Completions",
                                    value: String(totalCompletions),
                                    subtitle: "This week",
                                    colorHex: "A8D8A8"
                                )
                                StatsCardView(
                                    title: "Avg Rate",
                                    value: "\(Int(averageRate * 100))%",
                                    subtitle: "Across habits",
                                    colorHex: "A8D8EA"
                                )
                                StatsCardView(
                                    title: "Best Habit",
                                    value: bestHabit?.habit.title ?? "None",
                                    subtitle: bestHabit == nil ? "-" : "Top completion",
                                    colorHex: "FFD4A3"
                                )
                                StatsCardView(
                                    title: "Best Streak",
                                    value: "\(bestStreak)",
                                    subtitle: "Days in a row",
                                    colorHex: "FFB5C2"
                                )
                            }

                            rankingSection(rankedHabits: rankedHabits)
                        }
                        .padding(16)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerView: some View {
        HStack {
            Text("Statistics")
                .font(.title.bold())
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
    }

    private var weekPicker: some View {
        HStack {
            Button(action: { weekStart = DateUtils.addDays(weekStart, -7) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.accent)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text("Week of \(DateUtils.shortLabel(weekStart))")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Button(action: { weekStart = DateUtils.addDays(weekStart, 7) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.accent)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
        )
    }

    private func rankingSection(rankedHabits: [HabitStats]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habits Ranking")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(Array(rankedHabits.enumerated()), id: \.element.habit.id) { index, item in
                let maxCompletions = max(rankedHabits.first?.completions ?? 1, 1)
                let percent = Double(item.completions) / Double(maxCompletions)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("#\(index + 1)")
                            .font(.caption.bold())
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 32, alignment: .leading)
                        Image(systemName: item.habit.symbolName)
                            .foregroundColor(Color(hex: item.habit.colorHex))
                        Text(item.habit.title)
                            .font(.subheadline.bold())
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Text("\(item.completions)/\(item.habit.goalPerWeek)")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    GeometryReader { geometry in
                        let width = geometry.size.width * percent
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.accent.opacity(0.15))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color(hex: item.habit.colorHex))
                                .frame(width: width, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
                )
            }
        }
    }
}

private struct HabitStats {
    let habit: Habit
    let completions: Int
    let streak: Int

    var completionRate: Double {
        guard habit.goalPerWeek > 0 else { return 0 }
        return min(Double(completions) / Double(habit.goalPerWeek), 1.0)
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
            .environmentObject(HabitStore())
    }
}
