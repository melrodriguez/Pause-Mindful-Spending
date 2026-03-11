import SwiftUI

struct WishlistView: View {
    
    @StateObject private var viewModel: WishlistViewModel
    @EnvironmentObject var session: AppSessionViewModel

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
                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
                            GridItem(.fixed(120), spacing: 8),
                            GridItem(.fixed(120), spacing: 8),
                            GridItem(.fixed(120), spacing: 8)],
                                     textSize: 15
                        )
                    case .single:
                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
                            GridItem(.fixed(350), spacing: 8)],
                                     textSize: 30
                        )
                    case .none:
                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
                            GridItem(.fixed(120), spacing: 8),
                            GridItem(.fixed(120), spacing: 8),
                            GridItem(.fixed(120), spacing: 8)],
                                     textSize: 15
                        )
                    }
                    
                    Color.clear
                        .frame(height: 70)
                }
                .onAppear {
                    viewModel.loadItems()
                }
            }
            .appBackground()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
