// WORK IN PROGRESS

import SwiftUI

struct CategoriesView: View {
    
    @StateObject private var viewModel: CategoriesViewModel
    @EnvironmentObject var session: AppSessionViewModel

    init(viewModel: CategoriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
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



//import SwiftUI
//
//struct EditCategoriesView: View {
//
////    let item: Item
////    let uid: String
//
//    // @StateObject private var viewModel: EditCategoriesViewModel
//
////    init(item: Item, uid: String) {
////        self.item = item
////        self.uid = uid
////        _viewModel = StateObject(wrappedValue: ItemLogViewModel(item: item))
////    }
//
//    var body: some View {
//        VStack {
//            AppHeader(title: "Edit Categories")
//            ScrollView {
//                VStack(spacing: 20) {
//                    Text("test")
//                }
//            }
//        }
//        .appBackground()
////        .onAppear {
////            // viewModel.loadCategories(uid: self.uid)
////        }
//
//    }
//}
//
//#Preview {
//    NavigationStack {
//        EditCategoriesView()
//    }
//}
//
//// image + gradient
////Image("MiffySweater")
////    .resizable()
////    .scaledToFill()
////    .frame(height: 400)
////    .clipped()
////
////LinearGradient(
////    gradient: Gradient(colors: [
////        Color.clear,
////        AppColors.bg1
////    ]),
////    startPoint: .top,
////    endPoint: .bottom
////)
////// Push the gradient down to the bottom
////.frame(height: 120)
////.frame(maxHeight: .infinity, alignment: .bottom)
//
//


