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
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AppHeader(title: "Settings")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ProfileSectionView(
                        username: viewModel.displayName,
                        email: viewModel.email,
                        photoUrl: viewModel.photoUrl
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
                                get: { viewModel.singleCardView },
                                set: { viewModel.updateWishlistLayout(singleCard: $0) }
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
                    
                    Color.clear.frame(height: 60)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .appBackground()
        .toolbar(.hidden, for: .tabBar)
    }
}
