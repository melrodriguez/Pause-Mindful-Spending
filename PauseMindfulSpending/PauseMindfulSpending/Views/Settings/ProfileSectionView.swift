import SwiftUI
import PhotosUI

struct ProfileSectionView: View {
    let username: String
    let email: String
    let photoUrl: String?
    var onImageSelected: (UIImage) -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            
            ZStack(alignment: .bottomTrailing) {
                
                ProfileImageView(photoUrl: photoUrl, size: 90)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "pencil")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.bg1)
                        .frame(width: 31, height: 31)
                        .background(AppColors.blue)
                        .clipShape(Circle())
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        guard let data = try? await newItem?.loadTransferable(type: Data.self),
                              let image = UIImage(data: data) else { return }
                        onImageSelected(image)
                    }
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
        photoUrl: nil,
        onImageSelected: { _ in }
    )
}
