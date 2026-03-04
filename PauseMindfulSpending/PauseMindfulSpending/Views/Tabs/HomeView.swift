import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Pause")
            
            Spacer()
        }
        .appBackground()
    }
}

#Preview {
    HomeView()
}
