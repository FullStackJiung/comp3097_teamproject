import Foundation

@MainActor
final class HabitStore: ObservableObject {
    @Published var habits: [Habit] {
        didSet { save() }
    }
    @Published var records: [HabitRecord] {
        didSet { save() }
    }
    @Published var isDarkMode: Bool {
        didSet { save() }
    }

    private let storageKey = "habitTrackerStore.v1"
    private let defaults = UserDefaults.standard
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        if let data = defaults.data(forKey: storageKey),
           let state = try? decoder.decode(PersistedState.self, from: data) {
            habits = state.habits
            records = state.records
            isDarkMode = state.isDarkMode
        } else {
            let seedHabits = SeedData.defaultHabits
            habits = seedHabits
            records = SeedData.defaultRecords(for: seedHabits)
            isDarkMode = false
        }
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    func addHabit(_ draft: HabitDraft) {
        let newHabit = Habit(
            id: UUID(),
            title: draft.title,
            symbolName: draft.symbolName,
            colorHex: draft.colorHex,
            goalPerWeek: draft.goalPerWeek,
            createdDate: Date(),
            isArchived: false
        )
        habits.append(newHabit)
    }

    func updateHabit(id: UUID, draft: HabitDraft) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[index].title = draft.title
        habits[index].symbolName = draft.symbolName
        habits[index].colorHex = draft.colorHex
        habits[index].goalPerWeek = draft.goalPerWeek
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        records.removeAll { $0.habitId == id }
    }

    func archiveHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[index].isArchived = true
    }

    func unarchiveHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[index].isArchived = false
    }

    func toggleCompletion(habitId: UUID, date: Date) {
        if let index = records.firstIndex(where: {
            $0.habitId == habitId && DateUtils.isSameDay($0.date, date)
        }) {
            records[index].isCompleted.toggle()
        } else {
            records.append(
                HabitRecord(
                    id: UUID(),
                    habitId: habitId,
                    date: DateUtils.startOfDay(date),
                    isCompleted: true
                )
            )
        }
    }

    func isCompletedOnDate(habitId: UUID, date: Date) -> Bool {
        records.first(where: {
            $0.habitId == habitId && $0.isCompleted && DateUtils.isSameDay($0.date, date)
        }) != nil
    }

    func getWeekCompletions(habitId: UUID, weekStart: Date) -> Int {
        let start = DateUtils.startOfWeek(weekStart)
        let end = DateUtils.addDays(start, 7)

        return records.filter { record in
            record.habitId == habitId &&
            record.isCompleted &&
            record.date >= start &&
            record.date < end
        }.count
    }

    func getStreak(habitId: UUID) -> Int {
        var streak = 0
        var current = DateUtils.startOfDay(Date())

        while isCompletedOnDate(habitId: habitId, date: current) {
            streak += 1
            current = DateUtils.addDays(current, -1)
        }

        return streak
    }

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    func resetAllData() {
        let seedHabits = SeedData.defaultHabits
        habits = seedHabits
        records = SeedData.defaultRecords(for: seedHabits)
        isDarkMode = false
    }

    private func save() {
        let state = PersistedState(habits: habits, records: records, isDarkMode: isDarkMode)
        if let data = try? encoder.encode(state) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct PersistedState: Codable {
    var habits: [Habit]
    var records: [HabitRecord]
    var isDarkMode: Bool
}
