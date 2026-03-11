import SwiftUI

struct TimersView: View {
    
    @StateObject private var viewModel: TimerViewModel
    @EnvironmentObject var session: AppSessionViewModel

    init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Timers")
            if (viewModel.timerItems.isEmpty) {
                EmptyListView()
            } else {
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
                    
                    switch session.userSettings?.wishlistLayout {
                        // TODO: Make this less hardcoded
                    case .grid:
                        TimerGrid(viewModel: viewModel, columns: [
                            GridItem(.fixed(180), spacing: 8),
                            GridItem(.fixed(180), spacing: 8)],
                                  textSize: 20
                        )
                    case .single:
                        TimerGrid(viewModel: viewModel, columns: [
                            GridItem(.fixed(350), spacing: 8)],
                                  textSize: 30
                        )
                    case .none:
                        TimerGrid(viewModel: viewModel, columns: [
                            GridItem(.fixed(180), spacing: 8),
                            GridItem(.fixed(180), spacing: 8)],
                                  textSize: 20
                        )
                    }
                    
                    Color.clear
                        .frame(height: 70)
                }
            }
        }
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.startTimer()
            viewModel.loadTimerItems()
        }
    }
}
