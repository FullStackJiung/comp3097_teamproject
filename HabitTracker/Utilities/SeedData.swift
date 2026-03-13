import Foundation

enum SeedData {
    static let defaultHabits: [Habit] = [
        Habit(
            id: UUID(),
            title: "Study",
            symbolName: "book",
            colorHex: "3B82F6",
            goalPerWeek: 5,
            createdDate: DateUtils.addDays(Date(), -30),
            isArchived: false
        ),
        Habit(
            id: UUID(),
            title: "Workout",
            symbolName: "figure.run",
            colorHex: "10B981",
            goalPerWeek: 3,
            createdDate: DateUtils.addDays(Date(), -25),
            isArchived: false
        ),
        Habit(
            id: UUID(),
            title: "Water",
            symbolName: "drop",
            colorHex: "06B6D4",
            goalPerWeek: 7,
            createdDate: DateUtils.addDays(Date(), -20),
            isArchived: false
        )
    ]

    static func defaultRecords(for habits: [Habit]) -> [HabitRecord] {
        var records: [HabitRecord] = []
        let today = DateUtils.startOfDay(Date())

        for dayOffset in 0..<14 {
            let date = DateUtils.addDays(today, -dayOffset)
            for (index, habit) in habits.enumerated() {
                let shouldComplete = (dayOffset + index) % 2 == 0
                if shouldComplete {
                    records.append(
                        HabitRecord(
                            id: UUID(),
                            habitId: habit.id,
                            date: date,
                            isCompleted: true
                        )
                    )
                }
            }
        }

        return records
    }
}
