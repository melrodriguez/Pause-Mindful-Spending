import SwiftUI

struct FloatingNavBar: View {
    let tabs: [NavBar]
    @Binding var selectedTab: NavBar

    @Namespace private var bubbleNS

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tabs) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        if selectedTab == tab {
                            Capsule()
                                .fill(AppColors.pink.opacity(0.18))
                                .matchedGeometryEffect(id: "bubble", in: bubbleNS)
                        }

                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                selectedTab == tab
                                ? AppColors.pink
                                : Color.secondary
                            )
                            .padding(.horizontal, 14)

                    }
                    .frame(height: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            Capsule()
                .fill(.thinMaterial)
                .shadow(radius: 8)
        )
    }
}
