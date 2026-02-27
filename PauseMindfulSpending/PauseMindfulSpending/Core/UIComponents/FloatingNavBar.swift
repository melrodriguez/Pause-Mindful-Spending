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
                                .fill(Color.accentColor.opacity(0.18))
                                .matchedGeometryEffect(id: "bubble", in: bubbleNS)
                        }

                        Text(tab.rawValue)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
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
        .padding(.horizontal, 18)
    }
}
