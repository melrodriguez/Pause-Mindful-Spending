import SwiftUI

struct TimersView: View {
    
    @StateObject private var viewModel: TimerViewModel
    @EnvironmentObject var session: AppSessionViewModel
    @State private var showingSortBySheet = false
    @State private var sortOrder = "Ascending"

    init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                AppHeader(title: "Timers")
                ScrollView {
                    HStack{
                        Spacer()
                        Button() {
                            showingSortBySheet = true
                        } label: {
                            Image("Sort")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    .padding(.trailing, 20)
                        
                    Divider()

                    if viewModel.timerItems.isEmpty {
                        Spacer()
                        VStack(alignment: .center) {
                            Image("GreyAppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .shadow(color: .black.opacity(0.5), radius: 8, x: 5, y: 5)
                        
                            Text("Nothing yet")
                                .font(AppFonts.bold(30))
                                .foregroundColor(AppColors.textSecondary)
                        
                            Text("Add before you buy - mindful spending starts with a single pause")
                                .font(AppFonts.regular(15))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 280)
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .opacity(0.7)
                        .padding(.top, 150)
                    } else {
                        switch session.userSettings?.wishlistLayout {
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
                .onAppear {
                    if !viewModel.timerItems.isEmpty {
                        viewModel.startTimer()
                    }
                }
            }
            .appBackground()
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                viewModel.getTimerItems(sortOrder: sortOrder)
            }
            .sheet(isPresented: $showingSortBySheet) {
                TimerSortBySheet(viewModel: viewModel, sortOrder: $sortOrder).presentationDetents([.medium, .large])
            }
            .onChange(of: sortOrder) {
                viewModel.getTimerItems(sortOrder: sortOrder)
            }
        }
    }
}
