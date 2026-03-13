import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showQuickAdd = false

    var body: some View {
        let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt
        let today = Date()
        let activeHabits = store.activeHabits
        let completedCount = activeHabits.filter {
            store.isCompletedOnDate(habitId: $0.id, date: today)
        }.count

        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView(date: today)

                ScrollView {
                    VStack(spacing: 16) {
                        if activeHabits.isEmpty {
                            EmptyStateView(
                                title: "No habits yet",
                                message: "Add your first habit to get started.",
                                systemImage: "target"
                            )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(activeHabits) { habit in
                                    HabitRowView(
                                        habit: habit,
                                        isCompleted: store.isCompletedOnDate(habitId: habit.id, date: today),
                                        weekProgress: store.getWeekCompletions(
                                            habitId: habit.id,
                                            weekStart: today
                                        ),
                                        onToggle: {
                                            store.toggleCompletion(habitId: habit.id, date: today)
                                        }
                                    )
                                }
                            }

                            ProgressRingView(completed: completedCount, total: activeHabits.count)
                                .padding(.top, 8)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .sheet(isPresented: $showQuickAdd) {
            HabitFormView(onComplete: { showQuickAdd = false })
                .environmentObject(store)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func headerView(date: Date) -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.title.bold())
                        .foregroundColor(AppColors.textPrimary)
                    Text(DateUtils.formattedDate(date))
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: { showQuickAdd = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add")
                            .font(.headline)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppColors.accent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                (colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        TodayView()
            .environmentObject(HabitStore())
    }
}
