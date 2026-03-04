import SwiftUI

struct AppHeader: View {
    
    // Text passed in by each page
    let title: String
    
    var body: some View {
        HStack {
            
            // Left side title
            Text(title)
                .font(AppFonts.title)
            
            Spacer()
            
            // Right side logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 28)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    AppHeader(title: "Pause")
}
