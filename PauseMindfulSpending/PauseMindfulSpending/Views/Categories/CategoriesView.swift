import SwiftUI
struct CategoriesView: View {
    @State var isShowingAddSheet: Bool = false
    let uid: String
    @StateObject private var viewModel: CategoriesViewModel
    var onCategoriesUpdated: () -> Void // Signal to EditItemLogView that categories were edited
    
    init(uid: String, onCategoriesUpdated: @escaping () -> Void) {
        self.uid = uid
        self.onCategoriesUpdated = onCategoriesUpdated
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }
    
    // based off of Timer grid
    var body: some View {
        VStack {
            AppHeader(title: "Edit Categories")
            
            // List of all categories
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryCell(
                            category: category,

                            editCategory: { newName in
                                viewModel.pressedEditButton(uid: self.uid, oldName: category, newName: newName)
                                onCategoriesUpdated()
                            },

                            deleteCategory: { 
                                viewModel.pressedDeleteButton(uid: self.uid, name: category)
                                onCategoriesUpdated()
                            }
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            
            // Press button to add category
            Button {
                isShowingAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
                    .frame(width: 60, height: 60)
                    .background(Color.backgroundFill)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            
            // Sheet pops up after pressing add button
            .sheet(isPresented: $isShowingAddSheet) {
                AddCategorySheet(
                    onSave: { newName, enableStreak in
                    
                        // Add new category to user data
                        viewModel.pressedAddButton(uid: uid, name: newName, enableStreak: enableStreak)
                         onCategoriesUpdated()

                        // Reload the cells 
                        viewModel.getCategoryNames(uid: uid) 
                        isShowingAddSheet = false
                    }
                )
                .presentationDetents([.medium])
            }
        }
        
        // Fetch category names for cells as soon as the view appears
        .onAppear {
            viewModel.getCategoryNames(uid: self.uid)
        }
        .appBackground()
    }
}

#Preview {

}
