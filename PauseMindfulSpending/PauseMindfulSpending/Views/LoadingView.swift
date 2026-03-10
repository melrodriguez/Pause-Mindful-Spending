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
                
                // Load at a natural pace (not instant)
                .task {
                    try? await Task.sleep(for: .seconds(2))
                }
        }
        .appBackground()
    }
}

#Preview {
    LoadingView()
}
