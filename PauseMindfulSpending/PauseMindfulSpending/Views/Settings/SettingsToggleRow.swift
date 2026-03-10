import SwiftUI

struct SettingsToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}
