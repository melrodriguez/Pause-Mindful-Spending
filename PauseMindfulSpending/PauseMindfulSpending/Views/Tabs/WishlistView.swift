import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel: WishlistViewModel
    
    init(viewModel: WishlistViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    let columns = [
        GridItem(.fixed(170), spacing: 20),
        GridItem(.fixed(170), spacing: 20)
    ]
    
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
                
                WishlistGrid(items: viewModel.items)
            }
            .onAppear {
                viewModel.loadItems()
            }
        }
        .appBackground()
    }
}
