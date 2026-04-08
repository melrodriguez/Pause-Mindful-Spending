import SwiftUI

struct DeleteItemPopup: View {
    @Binding var showDeletePopup: Bool
    var deleteItem: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .foregroundColor(AppColors.pink)
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Remove this item?")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Feel free to add it again anytime.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.pink.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.pink.opacity(0.25), lineWidth: 1)
                        )
                )

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        deleteItem()
                    } label: {
                        Text("Remove Item")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(AppColors.pink)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)

                    Button {
                        showDeletePopup = false
                    } label: {
                        Text("Keep It")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(AppColors.textSecondary.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .navigationTitle("Remove Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showDeletePopup = false }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    DeleteItemPopup(showDeletePopup: .constant(true), deleteItem: {})
}
