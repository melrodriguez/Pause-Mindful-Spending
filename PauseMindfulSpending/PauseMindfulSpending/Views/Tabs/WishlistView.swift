import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel: WishlistViewModel
    @EnvironmentObject var session: AppSessionViewModel

    init(viewModel: WishlistViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
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
                case .grid:
                    WishlistGrid(items: viewModel.items, columnsChange: [
                        GridItem(.fixed(120), spacing: 8),
                        GridItem(.fixed(120), spacing: 8),
                        GridItem(.fixed(120), spacing: 8)]
                    )
                case .single:
                    WishlistGrid(items: viewModel.items, columnsChange: [
                        GridItem(.fixed(350), spacing: 8)]
                    )
                case .none:
                    WishlistGrid(items: viewModel.items, columnsChange: [
                        GridItem(.fixed(120), spacing: 8),
                        GridItem(.fixed(120), spacing: 8),
                        GridItem(.fixed(120), spacing: 8)]
                    )
                }
            }
            .onAppear {
                viewModel.loadItems()
            }
        }
        .appBackground()
    }
}
