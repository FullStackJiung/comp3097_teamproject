import SwiftUI

struct HabitFormView: View {
    @EnvironmentObject private var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    let habit: Habit?
    let onComplete: () -> Void

    @State private var title: String
    @State private var symbolName: String
    @State private var colorHex: String
    @State private var goalPerWeek: Int

    private let symbols = [
        "book",
        "figure.run",
        "drop",
        "leaf",
        "paintbrush",
        "dumbbell",
        "fork.knife",
        "bed.double",
        "target",
        "pencil",
        "music.note",
        "phone"
    ]

    private let colors = [
        "A8D8EA",
        "A8D8A8",
        "B8A0D9",
        "FFD4A3",
        "FFB5C2",
        "C2E7C3",
        "F5D0A9",
        "D4C4E8"
    ]

    init(habit: Habit? = nil, onComplete: @escaping () -> Void) {
        self.habit = habit
        self.onComplete = onComplete
        _title = State(initialValue: habit?.title ?? "")
        _symbolName = State(initialValue: habit?.symbolName ?? "book")
        _colorHex = State(initialValue: habit?.colorHex ?? "B8A0D9")
        _goalPerWeek = State(initialValue: habit?.goalPerWeek ?? 3)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Name") {
                    TextField("Morning routine", text: $title)
                }

                Section("Symbol") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                        ForEach(symbols, id: \.self) { symbol in
                            Button(action: { symbolName = symbol }) {
                                Image(systemName: symbol)
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(symbolName == symbol ? AppColors.accent.opacity(0.2) : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            Button(action: { colorHex = hex }) {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(colorHex == hex ? AppColors.accent : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Weekly Goal") {
                    Stepper("\(goalPerWeek) times", value: $goalPerWeek, in: 1...14)
                }
            }
            .navigationTitle(habit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { close() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func close() {
        onComplete()
        dismiss()
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let draft = HabitDraft(
            title: trimmedTitle,
            symbolName: symbolName,
            colorHex: colorHex,
            goalPerWeek: goalPerWeek
        )

        if let habit {
            store.updateHabit(id: habit.id, draft: draft)
        } else {
            store.addHabit(draft)
        }

        close()
    }
}

#Preview {
    HabitFormView(onComplete: {})
        .environmentObject(HabitStore())
}
