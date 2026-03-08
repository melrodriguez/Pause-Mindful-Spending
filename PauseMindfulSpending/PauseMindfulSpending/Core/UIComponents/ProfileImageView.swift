import SwiftUI

struct ProfileImageView: View {
    
    let photoUrl: String?
    var size: CGFloat = 90
    
    var body: some View {
        Group {
            if let photoUrl,
               !photoUrl.isEmpty,
               let url = URL(string: photoUrl) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    fallbackImage
                }
                
            } else {
                fallbackImage
            }
        }
        .frame(width: size, height: size)
        .background(Color.gray.opacity(0.25))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var fallbackImage: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .padding(size * 0.2)
    }
}
