import SwiftUI

struct DeleteItemPopup: View {

    @Binding var showDeletePopup: Bool
    
    // When you call this method, return to TimerView
    var deleteItem: () -> Void
    
    var body: some View {

        VStack(spacing: 20) {

            Text("Would you like to remove this item?")
                .font(AppFonts.subhead.weight(.semibold))
                .frame(alignment: .center)

            Text("Feel free to add the item again anytime!")
                .font(AppFonts.subhead)
                .foregroundColor(AppColors.textSecondary)
                .frame(alignment: .center)

            VStack(spacing: 12) {

                Button {
                    deleteItem()
                } label: {
                    Text("Remove Item")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(AppColors.textSecondary.opacity(0.15))
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(8)
                }

                Button {
                    showDeletePopup = false
                } label: {
                    Text("Keep It")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(AppColors.textSecondary.opacity(0.15))
                        .foregroundColor(AppColors.textPrimary)
                        .cornerRadius(8)
                }
                
            }
            
        }
        .padding(24)
        .background(AppColors.bg1)
        .shadow(radius: 20)
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    // DeleteItemPopup()
}
