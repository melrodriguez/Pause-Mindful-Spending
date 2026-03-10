import SwiftUI

struct TimerGrid: View {
    
    @ObservedObject var viewModel: TimerViewModel
    
    let columns = [
        GridItem(.fixed(180), spacing: 8),
        GridItem(.fixed(180), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.timerItems) { item in
                TimerCell(viewModel: viewModel, item: item)
            }
        }
    }
}
