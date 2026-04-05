import SwiftUI

struct TimerSortBySheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TimerViewModel
    let orderList: [String] = ["Ascending", "Descending"]
    @Binding var sortOrder: String

    
    var body: some View {
        NavigationStack {
            List {
                Section("Order") {
                    ForEach(orderList, id: \.self) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            HStack {
                                Text(order)
                                Spacer()
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

