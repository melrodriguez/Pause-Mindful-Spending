import SwiftUI

struct ProfileSectionView: View {
    let username: String
    let email: String
    let photoUrl: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            
            ZStack(alignment: .bottomTrailing) {
                
                ProfileImageView(photoUrl: photoUrl, size: 90)
                
                Button {
                    // TODO - profile picture editing
                } label: {
                    Image(systemName: "pencil")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.bg1)
                        .frame(width: 31, height: 31)
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
    ProfileSectionView(
        username: "bob",
        email: "bob@gmail.com",
        photoUrl: nil
    )
}
