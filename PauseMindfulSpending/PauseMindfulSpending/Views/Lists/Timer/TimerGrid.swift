import SwiftUI

struct TimerGrid: View {
    
    @ObservedObject var viewModel: TimerViewModel
    @EnvironmentObject var session: AppSessionViewModel
    
    let columns: [GridItem]
    let textSize: CGFloat

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(session.timerItems) { item in
                TimerCell(viewModel: viewModel, item: item, textSize: textSize)
            }
        }
    }
}
