import SwiftUI

struct TimersView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Timers")
            
            Spacer()
        }
        .appBackground()
    }
}

#Preview {
    TimersView()
}
