// Modulated delete account, but for deleting categories

import SwiftUI

struct DeleteCategorySheet: View {
    let currentName: String
    let onConfirm: (String) -> Void
    
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    // Same across the 3 sheets
    private var canSubmit: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 && !isLoading
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Warning banner
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.pink)
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("This can't be undone")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Your category will be permanently deleted from all items that share it.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()
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
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current category name: \(currentName)")
                        .font(AppFonts.subhead)
                        .foregroundColor(AppColors.textSecondary)
                    TextField("Enter the category name to confirm.", text: $name)
                        .font(AppFonts.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gray.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(errorMessage != nil ? AppColors.mainGreen : Color.gray.opacity(0.25), lineWidth: 1)
                                )
                        )
                }
                
                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.mainGreen)
                }
                
                // Save button
                Button {
                    submit()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        }
                        Text(isLoading ? "Saving..." : "Save changes")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(canSubmit ? AppColors.mainGreen : AppColors.mainGreen.opacity(0.4))
                    )
                }
                .disabled(!canSubmit)
                Spacer()
            }
            .padding(24)
            .navigationTitle("Delete Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
        }
    }
    
    // Type category name to confirm deletion
    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed == currentName else {
            errorMessage = "Category name must match to proceed."
            return
        }
        errorMessage = nil
        isLoading = true
        onConfirm(trimmed)
        
        // Parent handles dismissal on success
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isLoading = false
        }
    }
}

#Preview {
    // DeleteCategorySheet(currentName: "Wishlist") { _ in }
}
