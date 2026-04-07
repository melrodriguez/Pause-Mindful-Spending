// Modulated from ItemLoggedView

import SwiftUI
import ConfettiSwiftUI

struct AdjustTimerResponseOverlay: View {
    
    var onDone: () -> Void = {}
    
    @State private var confettiCounter: Int = 0
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing : 20) {
                Text("You extended the time you need to Pause.")
                    .font(AppFonts.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Button {
                    onDone()
                } label: {
                    Text("I can keep going!")
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



