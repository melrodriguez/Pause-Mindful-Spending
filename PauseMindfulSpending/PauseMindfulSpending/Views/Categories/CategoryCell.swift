import SwiftUI

// CategoryCell has 2 buttons: edit and delete
// Clicking either results in a sheet appearing

struct CategoryCell: View {
    let category: String
    
    // Same mechanism in DeleteItemPopup
    var editCategory: ((String) -> Void)? = nil
    var deleteCategory: (() -> Void)? = nil
    
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteSheet = false
    @State private var editedName: String = ""
    
    var body: some View {
        HStack(spacing: 8) {
            Text(category)
                .font(AppFonts.subhead)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            // Edit button
            Button {
                editedName = category
                isShowingEditSheet = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Delete button
            Button {
                isShowingDeleteSheet = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.mainPink)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .background(AppColors.accentGreen)
        .cornerRadius(8)
        
        // Sheet when edit button is pressed on the cell
        .sheet(isPresented: $isShowingEditSheet) {
            EditCategorySheet(currentName: category) { newName in
                editCategory?(newName)
            }
            .presentationDetents([.medium])
        }
        
        // Same but for delete button
        .sheet(isPresented: $isShowingDeleteSheet) {
            DeleteCategorySheet(currentName: category) { _ in
                deleteCategory?()
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    // CategoryCell(category: "Instagram Finds")
}
