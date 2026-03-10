import SwiftUI

struct ItemLogView: View {
    // temporary
    let moods = ["😐","🙂","😊","😍","🤩","😬"]

    /*
     variables:
     
     viewModel = ItemPageViewModel
     
     viewModel
       |- item
     
     variables i need:
     item.name
     item.createdAt
     for each : item.category (collection), display
     item.cost
     mood stuff = TODO
     item.notes
     item. get timerID and etc.
     
     navigation:
     
     editTimerButton
     editItemButton
     deleteItemButton
     */
    
    var body: some View {
        ScrollView {
            AppHeader(title:"")
            VStack(spacing: 20) {
                // image
                Image("MiffySweater") // from assets
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()
                    .cornerRadius(16) // TODO: change in the future

                // title, date, categories
                VStack(alignment: .leading, spacing: 4) {

                    Text("Miffy Sweater")
                        .font(AppFonts.title)

                    Text("February 18, 2026")
                        .font(AppFonts.subhead)

                    // TODO: insert list of categories
                    Text("Instagram Finds")
                        .font(AppFonts.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // price
                Text("$50") // TODO: insert real price
                    .font(AppFonts.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // TODO: make not static
                // mood (static)
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

                    Text("i saw it on instagram and it was really cute :(")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(height: 120, alignment: .topLeading)
                        .padding(8)
                        .background(AppColors.accentGreen.opacity(0.15))
                        .cornerRadius(10)
                        
                }

                // timer
                Text("1d 2hr 57min")
                    .font(AppFonts.headline)

                // buttons
                HStack(spacing: 16) {
                    Button("Edit Item") {
                        // viewModel.pressedEditItemButton()
                    } .buttonStyle(.borderedProminent)
                        
                    Button("Edit Timer") {
                        // viewModel.pressedEditTimerButton()
                    } .buttonStyle(.borderedProminent)
                    
                    Button("Delete Item") {
                        // viewModel.pressedDeleteItemButton()
                    } .buttonStyle(.bordered)
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
