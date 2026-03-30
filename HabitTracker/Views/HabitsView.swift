import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddHabit = false
    @State private var showArchived = false

    var body: some View {
        let background = colorScheme == .dark ? AppColors.backgroundDark : AppColors.backgroundAlt
        let activeHabits = store.activeHabits
        let archivedHabits = store.habits.filter { $0.isArchived }

        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                if activeHabits.isEmpty && archivedHabits.isEmpty {
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

                        if !archivedHabits.isEmpty {
                            Section {
                                Button(action: { withAnimation { showArchived.toggle() } }) {
                                    HStack {
                                        Image(systemName: "archivebox")
                                            .foregroundColor(AppColors.textSecondary)
                                        Text("Archived (\(archivedHabits.count))")
                                            .foregroundColor(AppColors.textSecondary)
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: showArchived ? "chevron.up" : "chevron.down")
                                            .foregroundColor(AppColors.textSecondary)
                                            .font(.caption)
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)

                                if showArchived {
                                    ForEach(archivedHabits) { habit in
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
                                            .opacity(0.6)
                                        }
                                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                store.deleteHabit(id: habit.id)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                            Button {
                                                store.unarchiveHabit(id: habit.id)
                                            } label: {
                                                Label("Unarchive", systemImage: "arrow.uturn.left")
                                            }
                                            .tint(.green)
                                        }
                                    }
                                }
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
