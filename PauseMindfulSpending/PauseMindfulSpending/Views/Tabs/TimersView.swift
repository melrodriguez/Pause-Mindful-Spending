import SwiftUI

struct TimersView: View {
    
    @StateObject private var viewModel: TimerViewModel
    
    init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Timers")
            ScrollView {
                HStack{
                    Spacer()
                    Menu {
                        Button("Category") {
                            print("Sort by Category")
                        }
                    } label: {
                        Image("Sort")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .padding(.trailing, 20)
                
                TimerGrid(viewModel: viewModel)
            }
            .onAppear {
                viewModel.startTimer()
                viewModel.loadTimerItems()
            }
        }
        .appBackground()
    }
}
