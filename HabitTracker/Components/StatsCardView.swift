import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: String
    let subtitle: String?
    let colorHex: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let cardColor = colorScheme == .dark ? AppColors.surfaceDark : AppColors.surface
        let accentColor = Color(hex: colorHex)

        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(accentColor)
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    StatsCardView(title: "Total", value: "12", subtitle: "This week", colorHex: "A8D8EA")
        .padding()
}
