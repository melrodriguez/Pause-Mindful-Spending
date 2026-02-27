import SwiftUI

struct AddItemLogView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Text("Add Item Log")
                .font(.title)
                .fontWeight(.semibold)
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}
