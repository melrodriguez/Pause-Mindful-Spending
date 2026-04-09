// modulated delete account sheet, but for editing categories


import FirebaseFirestore
    
import SwiftUI
struct EditCategorySheet: View {
    private let firestoreService = FireStoreService()
    
    let uid: String
    let currentName: String
    let onSave: (String) -> Void
    
    @State private var name = ""
    @State private var isNameUnique: Bool = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private var canSubmit: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 && (!isLoading && isNameUnique)
    }
    
    func isCategoryNameUnique(name: String) async -> Bool {
          await withCheckedContinuation { continuation in
              firestoreService.fetchCategoryIdUsingName(uid: self.uid, name: self.name) { uid in
                  continuation.resume(returning: uid == nil)
              }
          }
      }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                // Info banner
                HStack(spacing: 12) {
                    Image(systemName: "pencil")
                        .foregroundColor(AppColors.mainGreen)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Rename your category")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.mainGreen.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.mainGreen.opacity(0.25), lineWidth: 1)
                        )
                )
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current category name: \(currentName)")
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
                                        .stroke(errorMessage != nil ? AppColors.mainGreen : Color.gray.opacity(0.25), lineWidth: 1)
                                )
                        )
                        .onChange(of: name) { _, newName in
                            Task { isNameUnique = await isCategoryNameUnique(name: newName) }
                        }
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
                        // when loading 
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
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            
            // Cancel button
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
    
    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            errorMessage = "Name must be at least 2 characters."
            return
        }
        
        Task {
            // Category nae shouldn't exist in the list already
            guard await isCategoryNameUnique(name: trimmed) else {
                isLoading = false
                errorMessage = "Name must be unique."
                return
            }
        }
        
        errorMessage = nil
        isLoading = true
        onSave(trimmed)
        
        // Parent handles dismissal on success
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isLoading = false
        }
    }
    
}
#Preview {
    // EditCategorySheet(currentName: "Wishlist") { _ in }
}
