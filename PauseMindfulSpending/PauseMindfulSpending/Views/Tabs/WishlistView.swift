import SwiftUI

struct WishlistView: View {
    
    @StateObject private var viewModel: WishlistViewModel
    @EnvironmentObject var session: AppSessionViewModel
    
    @State private var showingSortBySheet = false
    @State private var selectedSortField: String? = nil
    @State private var selectedSortName: String? = nil

    init(viewModel: WishlistViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack { // wrap entire body in nav stack
            VStack(alignment: .leading) {
                AppHeader(title: "Wishlist")
                ScrollView {
                    HStack {
                        Spacer()
                        ProfileImageView(photoUrl: nil, size: 80)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(viewModel.displayName)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.mainGreen)
                        Spacer()
                    }
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
                    
                    if viewModel.items.isEmpty {
                        //EmptyListView()
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
                        .padding(.top , 100)
                    } else {
                        switch session.userSettings?.wishlistLayout {
                        case .grid:
                            WishlistGrid(viewModel: viewModel, columns: [
                                GridItem(.fixed(120), spacing: 8),
                                GridItem(.fixed(120), spacing: 8),
                                GridItem(.fixed(120), spacing: 8)],
                                         textSize: 15
                            )
                        case .single:
                            WishlistGrid(viewModel: viewModel, columns: [
                                GridItem(.fixed(350), spacing: 8)],
                                         textSize: 30
                            )
                        case .none:
                            WishlistGrid(viewModel: viewModel, columns: [
                                GridItem(.fixed(120), spacing: 8),
                                GridItem(.fixed(120), spacing: 8),
                                GridItem(.fixed(120), spacing: 8)],
                                         textSize: 15
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
                viewModel.startItemListener()
            }
            .sheet(isPresented: $showingSortBySheet) {
                SortBySheet(viewModel: viewModel, selectedSortField: $selectedSortField, selectedSortName: $selectedSortName).presentationDetents([.medium, .large])
            }
            .onChange(of: selectedSortName) { _, newValue in
                if let fieldName = selectedSortField,
                   let fieldValue = selectedSortName {
                    if fieldName == "status" {
                        viewModel.filterByStatus(status: fieldValue)
                    }
                    if fieldName == "category" {
                        viewModel.filterByCategory(categoryId: fieldValue)
                    }
                }
            }
            .onDisappear() {
                selectedSortName = nil
                selectedSortField = nil
            }
        }
    }
}
