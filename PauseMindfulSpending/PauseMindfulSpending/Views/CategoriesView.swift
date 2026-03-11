// WORK IN PROGRESS

import SwiftUI

struct CategoriesView: View {
    
    @StateObject private var viewModel: CategoriesViewModel
    @EnvironmentObject var session: AppSessionViewModel

    init(viewModel: CategoriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Based off of WishlistGrid
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                AppHeader(title: "Edit Categories")
                ScrollView {
//                    
//                    switch session.userSettings?.wishlistLayout {
//                    case .grid:
//                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
//                            GridItem(.fixed(120), spacing: 8),
//                            GridItem(.fixed(120), spacing: 8),
//                            GridItem(.fixed(120), spacing: 8)],
//                                     textSize: 15
//                        )
//                    case .single:
//                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
//                            GridItem(.fixed(350), spacing: 8)],
//                                     textSize: 30
//                        )
//                    case .none:
//                        WishlistGrid(viewModel: viewModel, items: viewModel.items, columns: [
//                            GridItem(.fixed(120), spacing: 8),
//                            GridItem(.fixed(120), spacing: 8),
//                            GridItem(.fixed(120), spacing: 8)],
//                                     textSize: 15
//                        )
//                    }
//                    Color.clear
//                        .frame(height: 70)
                }
                .onAppear {
                    // viewModel.loadItems()
                }
            }
            .appBackground()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    // CategoriesView(viewModel: <#T##WishlistViewModel#>)
}
