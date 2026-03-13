import Foundation

@MainActor
final class HabitStore: ObservableObject {
    @Published var habits: [Habit] {
        didSet { save() }
    }
    @Published var records: [HabitRecord] {
        didSet {
            rebuildCache()
            save()
        }
    }
    @Published var isDarkMode: Bool {
        didSet { save() }
    }

    private let storageKey = "habitTrackerStore.v1"
    private let defaults = UserDefaults.standard
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // O(1) lookup: "habitId|dayTimestamp" -> isCompleted
    private var completionCache: [String: Bool] = [:]

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
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

        rebuildCache()
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    // MARK: - Cache

    private func cacheKey(habitId: UUID, date: Date) -> String {
        "\(habitId.uuidString)|\(Int(DateUtils.startOfDay(date).timeIntervalSince1970))"
    }

    private func rebuildCache() {
        completionCache = Dictionary(
            records.map { ($0.habitId, $0.date, $0.isCompleted) }
                   .map { (cacheKey(habitId: $0.0, date: $0.1), $0.2) },
            uniquingKeysWith: { _, new in new }
        )
    }

    // MARK: - Habit Management

    func addHabit(_ draft: HabitDraft) {
        habits.append(Habit(
            id: UUID(),
            title: draft.title,
            symbolName: draft.symbolName,
            colorHex: draft.colorHex,
            goalPerWeek: draft.goalPerWeek,
            createdDate: Date(),
            isArchived: false
        ))
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

    // MARK: - Tracking

    func toggleCompletion(habitId: UUID, date: Date) {
        if let index = records.firstIndex(where: {
            $0.habitId == habitId && DateUtils.isSameDay($0.date, date)
        }) {
            records[index].isCompleted.toggle()
        } else {
            records.append(HabitRecord(
                id: UUID(),
                habitId: habitId,
                date: DateUtils.startOfDay(date),
                isCompleted: true
            ))
        }
    }

    func isCompletedOnDate(habitId: UUID, date: Date) -> Bool {
        completionCache[cacheKey(habitId: habitId, date: date)] == true
    }

    func getWeekCompletions(habitId: UUID, weekStart: Date) -> Int {
        let start = DateUtils.startOfWeek(weekStart)
        return (0..<7).filter {
            isCompletedOnDate(habitId: habitId, date: DateUtils.addDays(start, $0))
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

    // MARK: - Settings

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    func resetAllData() {
        let seedHabits = SeedData.defaultHabits
        habits = seedHabits
        records = SeedData.defaultRecords(for: seedHabits)
        isDarkMode = false
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? encoder.encode(
            PersistedState(habits: habits, records: records, isDarkMode: isDarkMode)
        ) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

private struct PersistedState: Codable {
    var habits: [Habit]
    var records: [HabitRecord]
    var isDarkMode: Bool
}
