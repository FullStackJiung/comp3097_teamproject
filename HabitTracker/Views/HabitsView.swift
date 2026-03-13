import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddHabit = false

    var body: some View {
        let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt
        let activeHabits = store.activeHabits

        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if activeHabits.isEmpty {
                    EmptyStateView(
                        title: "No active habits",
                        message: "Create your first habit to start building routines.",
                        systemImage: "list.bullet.clipboard"
                    )
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(activeHabits) { habit in
                            NavigationLink {
                                HabitDetailView(habitId: habit.id)
                            } label: {
                                HabitRowView(
                                    habit: habit,
                                    isCompleted: store.isCompletedOnDate(habitId: habit.id, date: Date()),
                                    weekProgress: store.getWeekCompletions(
                                        habitId: habit.id,
                                        weekStart: Date()
                                    ),
                                    onToggle: nil
                                )
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    store.deleteHabit(id: habit.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    store.archiveHabit(id: habit.id)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(AppColors.accent)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            HabitFormView(onComplete: { showAddHabit = false })
                .environmentObject(store)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerView: some View {
        HStack {
            Text("Habits")
                .font(.title.bold())
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { showAddHabit = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(AppColors.accent)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface)
    }
}

#Preview {
    NavigationStack {
        HabitsView()
            .environmentObject(HabitStore())
    }
}
