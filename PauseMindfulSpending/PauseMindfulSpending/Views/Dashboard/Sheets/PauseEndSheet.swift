import SwiftUI

// A Pause has ended !
struct PauseEndSheet: View {
    let item: TimerItem
    let onCompletedPause: () -> Void
    let onBoughtItem: () -> Void
    let onAdjustTimer: () -> Void
    
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
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: 200, height: 200)
                        .foregroundColor(AppColors.textSecondary.opacity(0.30))
                    
                    Text("Picture coming soon!")
                        .foregroundColor(.white)
                }
                
                Text("Miffy Sweater") // insert real
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("$50") // insert real
                    .font(AppFonts.subhead)
                    .foregroundColor(AppColors.textPrimary)
                                
                VStack (alignment: .leading) {
                    HStack {
                        completedItemButton()
                        Text("I don't want to buy this anymore")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                    }

                    HStack {
                        boughtItemButton()

                        Text("I bought this already")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    HStack {
                        timerButton()
                        Text("I need more time to pause")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
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
        .transition(.move(edge: .bottom).combined(with: .opacity))

    }
}

#Preview {
    // PauseEndSheet()
}
