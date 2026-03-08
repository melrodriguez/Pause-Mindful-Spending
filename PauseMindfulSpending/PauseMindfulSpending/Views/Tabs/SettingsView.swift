import SwiftUI

struct SettingsView: View {
    
    @AppStorage("haptics_enabled") private var hapticsEnabled = true
    @AppStorage("night_mode") private var nightMode = false
    @AppStorage("wishlist_single_card") private var singleCardView = false
    
    // dummy for now
    @State private var cameraAccessOn = true
    @State private var libraryAccessOn = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AppHeader(title: "Settings")
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    ProfileSectionView(
                        username: "username",
                        email: "username@gmail.com"
                    )
                    .padding(.top, 20)
                    
                    SettingsSectionView(title: "Preferences") {
                        SettingsToggleRow(
                            title: "Haptics",
                            systemImage: "speaker.wave.2",
                            isOn: $hapticsOn
                        )
                        
                        Divider()
                        
                        SettingsToggleRow(
                            title: "Night mode",
                            systemImage: "moon",
                            isOn: $nightModeOn
                        )
                        
                        Divider()
                        
                        SettingsToggleRow(
                            title: "Wishlist single card view",
                            systemImage: "rectangle.grid.1x2",
                            isOn: $singleCardViewOn
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .appBackground()
    }
}

#Preview {
    SettingsView()
}
