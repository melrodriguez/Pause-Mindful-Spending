import SwiftUI

struct CategoryCell: View {
    
    let category: String
    
//    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            
            Text(category)
                .font(.subheadline)
                .foregroundColor(.white)
            
//            Button {
//                onDelete?()
//            } label: {
//                Image(systemName: "xmark")
//                    .foregroundColor(.white)
//            }
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
