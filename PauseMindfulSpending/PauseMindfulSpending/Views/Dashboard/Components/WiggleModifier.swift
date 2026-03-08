import SwiftUI

// Modifier for the wiggle animation
struct WiggleModifier: ViewModifier {
    let isWiggling: Bool
    @State private var rotate = false
    @State private var bounce = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? (rotate ? 1.5 : -1.5) : 0))
            .offset(y: isWiggling ? (bounce ? 1 : -1) : 0)
            .animation(
                isWiggling
                ? .easeInOut(duration: 0.14).repeatForever(autoreverses: true)
                : .default,
                value: rotate
            )
            .animation(
                isWiggling
                ? .easeInOut(duration: 0.18).repeatForever(autoreverses: true)
                : .default,
                value: bounce
            )
            .onAppear {
                if isWiggling {
                    rotate = true
                    bounce = true
                }
            }
            .onChange(of: isWiggling) { _, newValue in
                if newValue {
                    rotate = true
                    bounce = true
                } else {
                    rotate = false
                    bounce = false
                }
            }
    }
}

extension View {
    func wiggle(_ isWiggling: Bool) -> some View {
        modifier(WiggleModifier(isWiggling: isWiggling))
        
    }
}
