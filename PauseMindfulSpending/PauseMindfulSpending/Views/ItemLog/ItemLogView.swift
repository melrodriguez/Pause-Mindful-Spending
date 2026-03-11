import SwiftUI

struct ItemLogView: View {
    // If the item is ever deleted, we need to pop off the nav stack
    // and go back to where we came from (either Timers View or Wishlist View)
    @Environment(\.dismiss) private var dismiss
    @State private var showDeletePopup = false
    @State private var showEditItemLog = false
    
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
    
    // I turned moodButton from AddItemLog into a view and spaced out the attributes
    // This can be made into a reusable component in the future
    struct MoodFaceView: View {
        let mood: (imageName: String, label: String)
        let selectedMood: String

        var body: some View {
            VStack(spacing: 4) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(selectedMood == mood.imageName ?
                                  AppColors.mainGreen : AppColors.textSecondary)
                    )

                Text(mood.label)
                    .font(.system(size: 10))
                    .foregroundColor(.primary)
            }
        }
    }
    
    // Same here; just views instead of buttons
    private func moodDisplayView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How I felt when I logged this item")
                .font(AppFonts.subhead)

            HStack(spacing: 8) {
                ForEach(moods, id: \.imageName) { mood in
                    MoodFaceView(
                        mood: mood,
                        selectedMood: viewModel.mood
                    )
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6).opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                
                VStack(spacing: 20) {
        
                    // title, date, category
                    VStack(alignment: .leading, spacing: 4) {

                        HStack {
                            Text(viewModel.name)
                                .font(AppFonts.title)
                            
                            Button {
                                showEditItemLog = true
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
                        Text(viewModel.categoryName ?? "")
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
                    // Similar to that in AddItemLogView
                    moodDisplayView()
                    
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
                            print("pressed edit timer - future release")
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
                            showDeletePopup = true
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
            // Only show back button when not on the pop up
            .toolbar(showDeletePopup ? .hidden : .visible, for: .navigationBar)
            .onAppear {
                viewModel.loadItem(uid: self.uid)
            }
            
            // Be careful with this!
            if (showDeletePopup) {
                // Blur the background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    DeleteItemPopup(showDeletePopup: $showDeletePopup,
                        deleteItem: {
                            print("deleted item")
                            viewModel.deleteItem(uid: uid)
                            dismiss()
                        }
                    )
                }
                
            }
            
            if (showEditItemLog) {
                EditItemLogView(
                    item: item,
                    showEditItemLog: $showEditItemLog,
                    vm: viewModel,
                    editItem: {
                        viewModel.updateItem(uid: uid)
                        showEditItemLog = false
                        print("ItemLogView -> Pressed edit item")
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        // ItemLogView()
    }
}
