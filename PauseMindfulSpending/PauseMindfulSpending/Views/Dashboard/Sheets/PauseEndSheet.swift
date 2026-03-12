import SwiftUI

// A Pause has ended !
struct PauseEndSheet: View {
    
    // Spawn delete item confirmation popup
    private func deleteItemButton() -> some View {
        Button {
            // print("delete item pressed")
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .regular))
                .frame(width: 64, height: 64)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainPink)
                .clipShape(Circle())
        }
        .foregroundColor(AppColors.textPrimary)
    }
    
    // Navigate to wishlist page
    private func boughtItemButton() -> some View {
        Button {
            // print("delete item pressed")
        } label: {
            Image(systemName: "cart")
                .font(.system(size: 24, weight: .regular))
                .frame(width: 64, height: 64)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainGreen)
                .clipShape(Circle())
        }
        .foregroundColor(AppColors.textPrimary)
    }
    
    // Navigate to item page
    private func timerButton() -> some View {
        Button {
            // print("delete item pressed")
        } label: {
            Image(systemName: "clock")
                .font(.system(size: 24, weight: .regular))
                .frame(width: 64, height: 64)
                .foregroundColor(AppColors.textPrimary)
                .background(Color.mainBlue)
                .clipShape(Circle())
        }
        .foregroundColor(AppColors.textPrimary)
    }

    var body: some View {
       
        ZStack {
            LinearGradient.timerGradient
                .ignoresSafeArea()
            
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                
                Spacer()
                                
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
                
                Spacer()
                
                HStack {
                    deleteItemButton()
                    boughtItemButton()
                    timerButton()
                }
                
                Spacer()
            }
            
        }
        .appBackground()
        .frame(width: 350, height: 550)
        // .shadow(radius: 20)
        .cornerRadius(20)
        .padding()

    }
}

#Preview {
    PauseEndSheet()
}
