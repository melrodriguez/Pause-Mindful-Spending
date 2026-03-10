import SwiftUI

struct LoadingView: View {

    var body: some View {
        
        VStack(spacing: AppLayout.horizontalScreenPadding) {
        
            Image("AppLogo")
                .frame(alignment: .center)
            
            Text("less impulse, more intention")
                .italic()
                .font(AppFonts.body)
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.4)

        }
        .appBackground()
    }
}

#Preview {
    LoadingView()
}
