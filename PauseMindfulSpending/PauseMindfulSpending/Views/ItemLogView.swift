import SwiftUI

struct ItemLogView: View {
        
    let item: Item
    let uid: String

    @StateObject private var viewModel: ItemLogViewModel
    
    init(item: Item, uid: String) {
        self.item = item
        self.uid = uid
        _viewModel = StateObject(wrappedValue: ItemLogViewModel(item: item))
    }
    
    // Temporary - same as AddItemLog
    var moods : [(imageName: String, label: String)] = [
        ("ExcitedFace", "Excited"),
        ("HappyFace", "Happy"),
        ("CalmFace", "Calm"),
        ("BoredFace", "Bored"),
        ("SadFace", "Sad"),
        ("AnxiousFace", "Anxious"),
        ("StressedFace", "Stressed")
    ]
    
    private func moodButtonView(mood: (imageName: String, label: String)) -> some View {
        VStack(spacing: 4) {
            Image(mood.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 38, height: 38)
                .background(
                    Circle().fill(
                        viewModel.mood == mood.imageName
                        ? Color.mainGreen
                        : Color(.systemGray4)
                    )
                )

            Text(mood.label)
                .font(.system(size: 10))
                .foregroundColor(.primary)
        }
    }
    
    var body: some View {
        AppHeader(title: "")
        ScrollView {
            
            VStack(spacing: 20) {
    
                // title, date, category
                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        Text(viewModel.name)
                            .font(AppFonts.title)
                        
                        Button {
                            viewModel.pressedEditItemButton()
                        } label: {
                            Image("Pencil")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        
                        Spacer()
                    }

                    Text(viewModel.formattedDate)
                        .font(AppFonts.subhead)
                    
                    // item category
                    Text(viewModel.categoryName)
                        .font(AppFonts.caption)
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white)
                        .cornerRadius(6)
            
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // price
                Text(viewModel.formattedPrice)
                    .font(AppFonts.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // mood selector
                VStack(alignment: .leading) {
                    Text("How I felt when I logged this item")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(moods, id: \.imageName) { mood in
                            moodButtonView(mood: mood)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6).opacity(0.8))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                
                // description
                VStack(alignment: .leading, spacing: 8) {
                    Text("What prompted me to want to purchase this item was...")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(viewModel.notes)
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

                // timer
                Text(viewModel.formattedTimer)
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
        .onAppear {
            viewModel.loadItem(uid: self.uid)
        }
        
    }
}

#Preview {
    NavigationStack {
        //ItemLogView()
    }
}

// image + gradient
//Image("MiffySweater")
//    .resizable()
//    .scaledToFill()
//    .frame(height: 400)
//    .clipped()
//
//LinearGradient(
//    gradient: Gradient(colors: [
//        Color.clear,
//        AppColors.bg1
//    ]),
//    startPoint: .top,
//    endPoint: .bottom
//)
//// Push the gradient down to the bottom
//.frame(height: 120)
//.frame(maxHeight: .infinity, alignment: .bottom)

