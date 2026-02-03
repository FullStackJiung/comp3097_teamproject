import Foundation

struct Habit: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var symbolName: String
    var colorHex: String
    var goalPerWeek: Int
    var createdDate: Date
    var isArchived: Bool
}

struct HabitRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var habitId: UUID
    var date: Date
    var isCompleted: Bool
}

struct HabitDraft: Hashable {
    var title: String
    var symbolName: String
    var colorHex: String
    var goalPerWeek: Int
}
