import SwiftUI

struct ItemLogView: View {
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

    var moods: [(imageName: String, label: String)] = [
        ("ExcitedFace", "Excited"),
        ("HappyFace", "Happy"),
        ("CalmFace", "Calm"),
        ("BoredFace", "Bored"),
        ("SadFace", "Sad"),
        ("AnxiousFace", "Anxious"),
        ("StressedFace", "Stressed")
    ]

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
                        Circle().fill(
                            selectedMood == mood.imageName
                                ? AppColors.mainGreen
                                : AppColors.textSecondary.opacity(0.2)
                        )
                    )
                Text(mood.label)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private func moodDisplayView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How I felt")
                .font(AppFonts.subhead)
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: 8) {
                ForEach(moods, id: \.imageName) { mood in
                    MoodFaceView(mood: mood, selectedMood: viewModel.mood)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColors.textSecondary.opacity(0.15), lineWidth: 1)
            )
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Hero image
                if let urlString = viewModel.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(ProgressView())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                }

                // Content card
                VStack(alignment: .leading, spacing: 20) {

                    // Title row
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.name)
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.textPrimary)

                            Text(viewModel.formattedDate)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)

                            if let category = viewModel.categoryName {
                                Text(category)
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(AppColors.accentGreen)
                                    .cornerRadius(6)
                            }
                        }

                        Spacer()

                        if item.status == "wishlist" {
                            Button {
                                showEditItemLog = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(AppColors.textSecondary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }

                    Divider()

                    // Price + timer in a row
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Price")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text(viewModel.formattedPrice)
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Pause timer")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.mainGreen)
                                Text(viewModel.formattedTimer)
                                    .font(AppFonts.subhead)
                                    .foregroundColor(AppColors.textPrimary)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppColors.textSecondary.opacity(0.15), lineWidth: 1)
                    )

                    // Mood
                    moodDisplayView()

                    // Notes
                    if !viewModel.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What prompted me")
                                .font(AppFonts.subhead)
                                .foregroundColor(AppColors.textSecondary)

                            Text(viewModel.notes)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(14)
                                .background(Color(.systemBackground))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppColors.textSecondary.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }

                    // Action buttons
                    VStack(spacing: 10) {
                        if item.status == "bought" {
                            Button {
                                viewModel.setBoughtItemToWishlist(uid: uid)
                                dismiss()
                            } label: {
                                Text("Move to Wishlist")
                                    .font(AppFonts.subhead)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(15)
                                    .background(AppColors.mainGreen)
                                    .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }

                        if item.status == "wishlist" {
                            Button {
                                viewModel.setItemAsBought(uid: uid)
                                dismiss()
                            } label: {
                                Text("Mark as Bought")
                                    .font(AppFonts.subhead)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(15)
                                    .background(AppColors.mainGreen)
                                    .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showDeletePopup = true
                        } label: {
                            Label("Remove Item", systemImage: "trash")
                                .font(AppFonts.subhead)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.pink)
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .background(AppColors.pink.opacity(0.1))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppColors.pink.opacity(0.25), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .appBackground()
        .onAppear {
            viewModel.loadItem(uid: uid)
        }
        .navigationDestination(isPresented: $showEditItemLog) {
            EditItemLogView(
                item: item,
                showEditItemLog: $showEditItemLog,
                vm: viewModel,
                editItem: {
                    viewModel.updateItem(uid: uid)
                }
            )
        }
        .sheet(isPresented: $showDeletePopup) {
            DeleteItemPopup(
                showDeletePopup: $showDeletePopup,
                deleteItem: {
                    viewModel.deleteItem(uid: uid)
                    dismiss()
                }
            )
            .presentationDetents([.height(280)])
        }

    }
}


#Preview {
    NavigationStack {
        // ItemLogView()
    }
}
