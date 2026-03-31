import SwiftUI

struct DeleteAccountSheet: View {
    let onConfirm: (String) -> Void

    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private var canSubmit: Bool {
        password.count >= 6 && !isLoading
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

                        Text("Your account, wishlist, and all data will be permanently deleted.")
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

                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your password to confirm")
                        .font(AppFonts.subhead)
                        .foregroundColor(AppColors.textSecondary)

                    SecureField("Password", text: $password)
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

                // Delete button
                Button {
                    submit()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        }
                        Text(isLoading ? "Deleting..." : "Delete my account")
                            .font(AppFonts.subhead)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(canSubmit ? AppColors.pink : AppColors.pink.opacity(0.4))
                    )
                }
                .disabled(!canSubmit)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private func submit() {
        errorMessage = nil
        isLoading = true
        onConfirm(password)

        // The sheet will be dismissed by session.deleteAccount on success
        // Stop loading after a timeout if nothing happens
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isLoading = false
        }
    }
}

#Preview {
    DeleteAccountSheet(onConfirm: { _ in })
}
