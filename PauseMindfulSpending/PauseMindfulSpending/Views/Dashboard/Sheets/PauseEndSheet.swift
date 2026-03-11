import SwiftUI

// A Pause has ended !
struct PauseEndSheet: View {
    // item
    //
    var body: some View {
        VStack {
            AppHeader(title: "")
                .padding()
            Text("A Pause has ended!")
                .font(AppFonts.title)
                .foregroundColor(AppColors.textPrimary)
            
            
        }
        
        
    }
}

#Preview {
    PauseEndSheet()
}
