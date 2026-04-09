import SwiftUI

struct CategoriesView: View {
    @State var isShowingAddSheet: Bool = false
    let uid: String
    @StateObject private var viewModel: CategoriesViewModel
    var onCategoriesUpdated: () -> Void

    init(uid: String, onCategoriesUpdated: @escaping () -> Void) {
        self.uid = uid
        self.onCategoriesUpdated = onCategoriesUpdated
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                AppHeader(title: "Edit Categories")

                if viewModel.categories.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tag")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.textSecondary.opacity(0.4))
                        Text("No categories yet")
                            .font(AppFonts.subhead)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Tap + to add your first category")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryCell(
                                    uid: uid,
                                    category: category,
                                    editCategory: { newName in
                                        viewModel.pressedEditButton(uid: uid, oldName: category, newName: newName)
                                        onCategoriesUpdated()
                                    },
                                    deleteCategory: {
                                        viewModel.pressedDeleteButton(uid: uid, name: category)
                                        onCategoriesUpdated()
                                    }
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 100) // clear floating button
                    }
                }
            }

            // Floating add button
            Button {
                viewModel.errorMessage = nil
                isShowingAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Category")
                        .font(AppFonts.subhead)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppColors.mainGreen)
                .cornerRadius(24)
                .shadow(color: AppColors.mainGreen.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddCategorySheet(
                onSave: { newName, enableStreak in
                    viewModel.pressedAddButton(uid: uid, name: newName, enableStreak: enableStreak)
                    if let error = viewModel.errorMessage {
                        return error
                    }
                    onCategoriesUpdated()
                    viewModel.getCategoryNames(uid: uid)
                    isShowingAddSheet = false
                    return nil
                }
            )
            .presentationDetents([.height(280)])
        }
        .onAppear {
            viewModel.getCategoryNames(uid: uid)
        }
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
    }
}
