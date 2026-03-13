import Foundation

enum DateUtils {
    static let calendar = Calendar.current

    // Cached formatters — DateFormatter is expensive to initialize
    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func startOfWeek(_ date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? startOfDay(date)
    }

    static func addDays(_ date: Date, _ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func formattedDate(_ date: Date) -> String {
        fullDateFormatter.string(from: date)
    }

    static func shortLabel(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
}
