import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.pink)
                .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .background(
            Circle()
                .fill(.thinMaterial)
                .shadow(radius: 8)
        )
    }
}
