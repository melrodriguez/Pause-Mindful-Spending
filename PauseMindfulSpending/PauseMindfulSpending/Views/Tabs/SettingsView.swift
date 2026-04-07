import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject var session: AppSessionViewModel
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // TODO - temp, need to implement camera perms
    @State private var cameraAccessOn = true
    @State private var libraryAccessOn = true
    
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AppHeader(title: "Settings")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ProfileSectionView(
                        username: viewModel.displayName,
                        email: viewModel.email,
                        photoUrl: viewModel.photoUrl,
                        onImageSelected: { image in
                            viewModel.updateProfilePicture(image: image)
                        }
                    )
                    .padding(.top, 20)
                    
                    SettingsSectionView(title: "Preferences") {
                        SettingsToggleRow(
                            title: "Haptics",
                            systemImage: "iphone.radiowaves.left.and.right",
                            isOn: Binding(
                                get: { session.userSettings?.isHapticsEnabled ?? false },
                                set: { session.updateHaptics($0) }
                            )
                        )
                        
                        Divider()
                        
                        SettingsToggleRow(
                            title: "Night mode",
                            systemImage: "moon",
                            isOn: Binding(
                                get: { session.userSettings?.isNightMode ?? false },
                                set: { session.updateNightMode($0) }
                            )
                        )
                        
                        Divider()
                        
                        SettingsToggleRow(
                            title: "Wishlist single card view",
                            systemImage: "rectangle.grid.1x2",
                            isOn: Binding(
                                get: { session.userSettings?.wishlistLayout == .single },
                                set: { isSingle in
                                    session.updateWishlistLayout(isSingle ? .single : .grid)
                                }
                            )
                        )
                    }
                    
                    SettingsSectionView(title: "Permissions") {
                        SettingsToggleRow(
                            title: "Allow camera access",
                            systemImage: "camera",
                            isOn: $cameraAccessOn
                        )
                        
                        Divider()
                        
                        SettingsToggleRow(
                            title: "Allow library access",
                            systemImage: "film",
                            isOn: $libraryAccessOn
                        )
                    }

                    // MARK: - Account actions
                    SettingsSectionView(title: "Account") {
                        // Logout row
                        Button {
                            session.logout()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right.square")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 20)

                                Text("Log out")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary.opacity(0.4))
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)

                        Divider()

                        // Delete account row
                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "trash")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.pink)
                                    .frame(width: 20)

                                Text("Delete account")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.pink)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.pink.opacity(0.4))
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
                
                Color.clear.frame(height: 60)
            }
        }
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingDeleteConfirmation) {
            DeleteAccountSheet(
                onConfirm: { password in
                    session.deleteAccount(password: password)
                }
            )
            .presentationDetents([.medium])
        }
    }
}
