// Modulated from ItemLoggedView

import SwiftUI

struct BoughtResponseOverlay: View {

    var onDone: () -> Void = {}

    private let affirmations = [
        "I am in control of my choices.",
        "My money reflects my values.",
        "The habits I build today shape the life I want tomorrow.",
        "Every pause is a step toward financial freedom."
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.blue.opacity(0.15))
                        .frame(width: 72, height: 72)

                    Image(systemName: "bag")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(AppColors.blue)
                }
                .padding(.top, 28)

                // Title
                Text("You bought an item")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                Text("That's okay — every day is a fresh start.")
                    .font(AppFonts.subhead)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                // Divider
                Rectangle()
                    .fill(AppColors.textSecondary.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                // Affirmations
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(affirmations, id: \.self) { line in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(AppColors.mainGreen)
                                .frame(width: 6, height: 6)
                                .padding(.top, 5)

                            Text(line)
                                .font(AppFonts.subhead)
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Button
                Button {
                    onDone()
                } label: {
                    Text("I'll Pause next time")
                        .font(AppFonts.subhead)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(AppColors.mainGreen)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    BoughtResponseOverlay(onDone: {})
}
