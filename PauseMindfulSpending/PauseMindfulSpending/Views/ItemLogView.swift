import SwiftUI

struct ItemLogView: View {
    
    // Able to get user info -> related item info
    @EnvironmentObject var session: AppSessionViewModel
    private let viewModel = ItemLogViewModel()
    
    // Temporary
    let moods = ["😐","🙂","😊","😍","🤩","😬"]

    
    /*
     viewModel
       |- item
     
     item.name
     item.createdAt
     for each : item.category (collection), display
     item.cost
     mood stuff = TODO
     item.notes
     item. get timerID and etc.
     
     */
    
    var body: some View {
        ScrollView {
            AppHeader(title:"")
                .padding()
            
            // Stacking toward the viewer
            ZStack(alignment: .topTrailing) {
                
                Image("MiffySweater")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        AppColors.bg1
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                // Push the gradient down to the bottom
                .frame(height: 120)
                .frame(maxHeight: .infinity, alignment: .bottom)

                Button {
                    viewModel.pressedEditItemButton()
                } label: {
                    Image("Pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                .padding(20)
            }
            .frame(height: 400)
            
            VStack(spacing: 20) {
    
                // title, date, category
                VStack(alignment: .leading, spacing: 4) {

                    Text("Miffy Sweater") // TODO: insert real
                        .font(AppFonts.title)

                    Text("February 18, 2026") // TODO: insert real
                        .font(AppFonts.subhead)
                    
                    // item category
                    Text("Instagram Finds") // TODO: insert real
                        .font(AppFonts.caption)
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white)
                        .cornerRadius(6)
            
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // price
                Text("$50") // TODO: insert real price
                    .font(AppFonts.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // TODO: make not static
                // mood selector
                VStack(alignment: .leading) {
                    Text("How I felt when I logged this item")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(
                                    mood == "😍" ? AppColors.accentGreen.opacity(0.50) : AppColors.accentGreen.opacity(0.15)
                                )
                                .clipShape(Circle())
                        }
                    }
                }
                
                // description
                VStack(alignment: .leading, spacing: 8) {
                    Text("What prompted me to want to purchase this item was...")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // TODO: insert real
                    Text("i saw it on instagram and it was really cute :(")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(minHeight: 150, alignment: .topLeading)
                        .padding(16)
                        .background(.white)
                        .foregroundStyle(AppColors.textSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(5)
                        
                }

                // TODO: insert real
                // timer
                Text("1d 2hr 57min")
                    .font(AppFonts.headline)

                // buttons
                HStack(spacing: 16) {

                    Button(action: {
                        viewModel.pressedEditTimerButton()
                    }) {
                        Text("Edit Timer")
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .font(AppFonts.subhead)
                            .background(AppColors.mainGreen)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }


                    Button(action: {
                        viewModel.pressedDeleteItemButton()
                    }) {
                        Text("Delete Item")
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .font(AppFonts.subhead)
                            .background(AppColors.mainGreen)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
        }
        .appBackground()
    }
}

#Preview {
    NavigationStack {
        ItemLogView()
    }
}
