import SwiftUI

struct PauseEndOverlay: View {
    let timerManager: TimerManager
    let onCompletedPause: () -> Void
    let onBoughtItem: () -> Void
    let onAdjustTimer: () -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your pause has ended")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("What would you like to do?")
                            .font(AppFonts.subhead)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

                // MARK: - Item info
                HStack(spacing: 14) {
                    // Image placeholder — compact and left-aligned
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.textSecondary.opacity(0.12))
                            .frame(width: 64, height: 64)

                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.textSecondary.opacity(0.4))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(timerManager.currentItemName ?? "Unknown Item")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(2)

                        Text(timerManager.formattedPrice)
                            .font(AppFonts.subhead)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: - Divider
                Rectangle()
                    .fill(AppColors.textSecondary.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 24)

                // MARK: - Action rows
                VStack(spacing: 0) {
                    actionRow(
                        icon: "checkmark",
                        iconColor: AppColors.mainGreen,
                        title: "I don't want it anymore",
                        subtitle: "Swipe right",
                        action: onCompletedPause
                    )

                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 24)

                    actionRow(
                        icon: "bag",
                        iconColor: AppColors.pink,
                        title: "I already bought it",
                        subtitle: "Swipe left",
                        action: onBoughtItem
                    )

                    Rectangle()
                        .fill(AppColors.textSecondary.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 24)

                    actionRow(
                        icon: "clock",
                        iconColor: AppColors.blue,
                        title: "I need more time to pause",
                        subtitle: "Swipe down",
                        action: onAdjustTimer
                    )
                }
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 20)
        }
        .offset(dragOffset)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let threshold: CGFloat = 50

                    if abs(horizontal) > abs(vertical) {
                        if horizontal > threshold {
                            withAnimation(.easeOut(duration: 0.18)) {
                                dragOffset = CGSize(width: 500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onCompletedPause()
                                dragOffset = .zero
                            }
                        } else if horizontal < -threshold {
                            withAnimation(.easeOut(duration: 0.18)) {
                                dragOffset = CGSize(width: -500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onBoughtItem()
                                dragOffset = .zero
                            }
                        } else {
                            withAnimation(.spring()) { dragOffset = .zero }
                        }
                    } else {
                        if vertical > threshold {
                            withAnimation(.easeOut(duration: 0.18)) {
                                dragOffset = CGSize(width: 0, height: 500)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onAdjustTimer()
                                dragOffset = .zero
                            }
                        } else {
                            withAnimation(.spring()) { dragOffset = .zero }
                        }
                    }
                }
        )
    }

    // MARK: - Action row builder

    private func actionRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.subhead)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(red: 0.97, green: 0.95, blue: 0.90).ignoresSafeArea()
    }
}
