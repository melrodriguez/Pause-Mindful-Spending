import SwiftUI

struct EmptyListView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            ZStack{
                Circle()
                    .fill(AppColors.ListCell)
                    .frame(width: 250)
                Image("GreyAppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 5, y: 5)
                
                VStack {
                    Text("No item yet...")
                        .font(AppFonts.bold(30))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Add an item, if you feel any impulses. We will help you puase and decide later")
                        .font(AppFonts.regular(15))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                        .foregroundColor(AppColors.textTertiary)
                        .offset(y: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: 180)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -60)
            
            
        }
        .appBackground()
    }
}

#Preview{
    EmptyListView()
}
