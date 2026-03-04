import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Settings")
            
            Spacer()
        }
        .appBackground()
    }
}

#Preview {
    SettingsView()
}
