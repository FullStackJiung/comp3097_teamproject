import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(AppColors.accent)
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "No habits yet",
        message: "Add your first habit to get started.",
        systemImage: "target"
    )
}
