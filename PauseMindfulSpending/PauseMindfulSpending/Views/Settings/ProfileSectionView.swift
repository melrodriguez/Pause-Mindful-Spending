import SwiftUI

struct ProfileSectionView: View {
    let username: String
    let email: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                
                // place pfp in circle later
                Circle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 90, height: 90)
                
                Button {
                    // edit tapped
                } label: {
                    Image(systemName: "pencil")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.bg1)
                        .frame(width: 25, height: 25)
                        .background(AppColors.blue)
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(username)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.mainGreen)
                
                Text(email)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProfileSectionView(username: "bob", email: "bob@gmail.com")
}
