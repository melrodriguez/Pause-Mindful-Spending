import SwiftUI

struct AddItemLogView: View {
    var body: some View {
        ZStack {
            Text("Add Item Log")
                .font(AppFonts.headline)
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
    }
}

#Preview {
    AddItemLogView()
}
