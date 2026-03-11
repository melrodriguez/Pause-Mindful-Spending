import SwiftUI

struct CategoryCell: View {
    
    let category: String
    
    // Same mechanism in DeleteItemPopup
    var deleteCategory: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            
            Text(category)
                .font(AppFonts.subhead)
                .foregroundColor(AppColors.textPrimary)
            
            Button {
                deleteCategory?()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.mainGreen)
        .cornerRadius(8)
    }
}

#Preview {
    CategoryCell(category: "Instagram Finds")
}
