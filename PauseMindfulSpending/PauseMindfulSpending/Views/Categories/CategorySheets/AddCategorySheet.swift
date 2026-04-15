// Modulated from the delete account sheet

import SwiftUI

struct AddCategorySheet: View {
    @State private var enableStreak = false
    
    var onSave: (String, Bool) -> String?
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // we're good to submit if the page isn't loading + category name length is at least 2 chars
    private var canSubmit: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 && !isLoading
    }
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category name")
                        .font(AppFonts.subhead)
                        .foregroundColor(AppColors.textSecondary)
                    TextField("Enter new name", text: $name)
                        .font(AppFonts.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.gray.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(errorMessage != nil ? AppColors.pink : Color.gray.opacity(0.25), lineWidth: 1)
                                )
                        )
                }
                
                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.pink)
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
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            
            // Top right cancel button
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
            
        }
    }
    
    // Last checks
    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.count >= 2 else {
            errorMessage = "Category name must be at least 2 characters."
            return
        }
        
        errorMessage = nil
        isLoading = true
        let error = onSave(trimmed, enableStreak)
        isLoading = false
        
        if let error = error {
            errorMessage = error
        } else {
            dismiss()
        }
        
        // Parent handles dismissal on success
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isLoading = false
        }
    }
}
#Preview {
    // AddCategorySheet(currentName: "Wishlist") { _ in }
}
