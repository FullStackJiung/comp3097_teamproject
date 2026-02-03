import SwiftUI

struct ProgressRingView: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.accent.opacity(0.2), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text("\(completed)/\(total)")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("Done")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(width: 120, height: 120)
    }
}

#Preview {
    ProgressRingView(completed: 3, total: 5)
        .padding()
}
