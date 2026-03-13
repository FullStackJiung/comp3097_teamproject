import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let weekProgress: Int
    let onToggle: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let cardColor = colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface
        let accentColor = Color(hex: habit.colorHex)

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.symbolName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(weekProgress)/\(habit.goalPerWeek) this week")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            if let onToggle {
                Button(action: onToggle) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isCompleted ? AppColors.accent : AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isCompleted ? AppColors.accent : AppColors.textSecondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColors.accent.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    HabitRowView(
        habit: Habit(
            id: UUID(),
            title: "Study",
            symbolName: "book",
            colorHex: "3B82F6",
            goalPerWeek: 5,
            createdDate: Date(),
            isArchived: false
        ),
        isCompleted: true,
        weekProgress: 3,
        onToggle: {}
    )
    .padding()
}
