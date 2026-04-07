import SwiftUI

// A Pause has ended !
struct PauseEndOverlay: View {
    let timerManager: TimerManager
    let onCompletedPause: () -> Void
    let onBoughtItem: () -> Void
    let onAdjustTimer: () -> Void

    // For dragging the overlay around (gestures)
    @State private var dragOffset: CGSize = .zero
    
    // Completed pause
    private func completedItemButton() -> some View {
        Button {
            onCompletedPause()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .regular))
                .frame(width: 48, height: 48)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainPink)
                .clipShape(Circle())
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .foregroundColor(AppColors.textPrimary)
    }
    
    private func boughtItemButton() -> some View {
        Button {
            onBoughtItem()
        } label: {
            Image(systemName: "cart")
                .font(.system(size: 20, weight: .regular))
                .frame(width: 48, height: 48)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainGreen)
                .clipShape(Circle())
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .foregroundColor(AppColors.textPrimary)
    }
    
    // Bring up AdjustTimer sheet
    private func timerButton() -> some View {
        Button {
            onAdjustTimer()
        } label: {
            Image(systemName: "clock")
                .font(.system(size: 20, weight: .regular))
                .frame(width: 48, height: 48)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainBlue)
                .clipShape(Circle())
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .foregroundColor(AppColors.textPrimary)
    }

    var body: some View {
       
        ZStack {
            LinearGradient.timerGradient
            
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                                                
                Text("A Pause has ended!")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.textPrimary)
                    .padding()
                
                // TODO - replace with actual image
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 200, height: 200)
                        .foregroundColor(AppColors.textSecondary.opacity(0.30))
                    
                    Text("Picture coming soon!")
                        .foregroundColor(.white)
                }
                
                Text("\(timerManager.currentItemName ?? "Unknown Item")")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(timerManager.formattedPrice)") // insert real
                    .font(AppFonts.subhead)
                    .foregroundColor(AppColors.textPrimary)
                                
                VStack (alignment: .leading) {
                    HStack {
                        completedItemButton()
                        
                        VStack (alignment: .leading, spacing: 6) {
                            Text("I don't want to buy this anymore")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Swipe right")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                       
                    }

                    HStack {
                        boughtItemButton()
                        
                        VStack (alignment: .leading, spacing: 6) {
                            Text("I bought this already")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Swipe left")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    HStack {
                        timerButton()
                        
                        VStack (alignment: .leading, spacing: 6) {
                            Text("I need more time to pause")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Swipe down")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
            }
        }
        .appBackground()
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding()
        .frame(maxHeight: 650)
        .offset(dragOffset)
        .transition(.move(edge: .bottom).combined(with: .opacity))

        .gesture(
            DragGesture()
                // Move to where the user drags it
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // Where we are on the screen
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let threshold: CGFloat = 50

                    // HORIZONTAL
                    if abs(horizontal) > abs(vertical) {
                        // Swipe right if you're done
                        if horizontal > threshold {
                            withAnimation(.easeOut(duration: 0.18)) {
                                dragOffset = CGSize(width: 500, height: 0) // swipe offscreen
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onCompletedPause()
                                dragOffset = .zero
                            }
                            
                        // Swipe left if you bought it
                        } else if horizontal < -threshold {
                            withAnimation(.easeOut(duration: 0.18)) {
                                dragOffset = CGSize(width: -500, height: 0)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onBoughtItem()
                                dragOffset = .zero
                            }
                        } else {
                            dragOffset = .zero
                        }
                        
                    // VERTICAL
                    } else {
                        withAnimation(.easeOut(duration: 0.18)) {
                            dragOffset = CGSize(width: 0, height: 500)
                        }
                        
                        // Swipe down if you want more tiime
                        if vertical > threshold {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onAdjustTimer()
                                dragOffset = .zero
                            }
                        } else {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
}

#Preview {
    // PauseEndOverlay()
}
