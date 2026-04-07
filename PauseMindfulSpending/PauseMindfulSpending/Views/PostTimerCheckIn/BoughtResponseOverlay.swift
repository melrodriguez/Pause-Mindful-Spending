// Modulated from ItemLoggedView

import SwiftUI

struct BoughtResponseOverlay: View {
    
    var onDone: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 10) {
                Text("You bought an item on your wishlist.")
                    .font(AppFonts.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Remember: \n\nI am in control of my choices. \n\nMy money reflects my values, and I decide what matters. \n\nThe habits I build today support the life I want tomorrow.")
                    .font(AppFonts.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Button {
                    onDone()
                } label: {
                    Text("I'll Pause next time!")
                        .font(AppFonts.subhead)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.buttonBack)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.buttonBorder))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(AppColors.backgroundGradient)
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    // ItemLoggedView(onContinue: {})
}



