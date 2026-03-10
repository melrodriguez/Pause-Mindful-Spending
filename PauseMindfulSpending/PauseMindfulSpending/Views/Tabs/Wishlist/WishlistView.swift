import SwiftUI

struct WishlistView: View {
    let columns = [
        GridItem(.fixed(170), spacing: 20),
        GridItem(.fixed(170), spacing: 20)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            AppHeader(title: "Wishlist")
            ScrollView {
                HStack {
                    Spacer()
                    ProfileImageView(photoUrl: nil, size: 80)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("sarah")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.mainGreen)
                    Spacer()
                }
                HStack{
                    Spacer()
                    Button {
                        print("button tapped")
                    } label: {
                        Image("Sort")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .padding(.trailing, 20)
                
                WishlistGrid()
            }
        }
        .appBackground()
    }
}

#Preview {
    WishlistView()
}
