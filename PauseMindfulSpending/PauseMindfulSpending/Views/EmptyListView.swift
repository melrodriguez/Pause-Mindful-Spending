import SwiftUI

struct EmptyListView: View {
    
    var body: some View {
        VStack(alignment: .center) {
            Image("GreyAppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .shadow(color: .black.opacity(0.5), radius: 8, x: 5, y: 5)
            
            Text("Nothing yet")
                .font(AppFonts.bold(30))
                .foregroundColor(AppColors.textSecondary)
            
            Text("Add before you buy - mindful spending starts with a single pause")
                .font(AppFonts.regular(15))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .foregroundColor(AppColors.textTertiary)
        }
        .appBackground()
        .opacity(0.7)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview{
    EmptyListView()
}
