import SwiftUI
import PhotosUI
struct AddItemLogView: View {
    var moods : [(imageName: String, label: String)] = [
        ("ExcitedFace", "Excited"),
        ("HappyFace", "Happy"),
        ("CalmFace", "Calm"),
        ("BoredFace", "Bored"),
        ("SadFace", "Sad"),
        ("AnxiousFace", "Anxious"),
        ("StressedFace", "Stressed")
    ]
    @State private var itemName: String = ""
    @State private var selectedCategory: String? = nil
    @State private var isCategoryExpanded: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageCaptured: UIImage? = nil
    @State private var selectedMood: String? = nil
    @State private var showTimerSheet: Bool = false
    @State private var showCamera: Bool = false
    @State private var permissionDenied: Bool = false
    
    private func moodButton(mood: (imageName: String, label: String)) -> some View {
        Button {
            selectedMood = selectedMood == mood.imageName ? nil : mood.imageName
        } label: {
            VStack(spacing: 4) {
                Image(mood.imageName).resizable().scaledToFit().frame(width: 38, height: 38).background(Circle().fill(selectedMood == mood.imageName ? Color.mainGreen : Color(.systemGray4)))
                Text(mood.label).font(.system(size: 10)).foregroundColor(.primary)
            }
        }
    }
    
    let testCategories = ["Food", "Online Shopping", "Clothes"]
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Divider()
            
            // bubble for text header
            Text("What item would you like to add?").font(AppFonts.headline).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
            
            // Item name input box
            VStack(alignment: .leading, spacing: 6){
                Text("Item Name").font(AppFonts.subhead)
                TextField("E.g. Iced Latte", text: $itemName).textFieldStyle(.roundedBorder).background(Color.gray)
            }
            
            // category section of input item
            VStack(alignment: .leading, spacing: 6) {
                Text("Category").font(AppFonts.subhead)
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isCategoryExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory ?? "Select Category").foregroundColor(selectedCategory == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down").foregroundColor(.gray)
                        }
                        .padding(10)
                        .background(Color.gray)
                    }
                    
                    if isCategoryExpanded {
                        Divider()
                        ForEach(testCategories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isCategoryExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(category).foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(10)
                                .background(Color.accentColor.opacity(0.15))
                            }
                            Divider()
                        }
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1)).cornerRadius(8)
            }
            
            // text box for price input
            VStack(alignment: .leading, spacing: 6){
                Text("Enter Price").font(AppFonts.subhead)
                TextField("$0.00", text: $itemName).textFieldStyle(.roundedBorder).background(Color.gray)
            }
            
            //photo gallery and camera section
            VStack(alignment: .leading, spacing: 10) {
                Text("Photo").font(AppFonts.subhead)
                HStack(spacing: 12) {
                    
                    Button {
                        showCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera").frame(maxWidth: .infinity).padding(10).background(Color.mainGreen).foregroundColor(.white).cornerRadius(8)
                    }
                    
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("From Gallery", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.mainGreen)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }.onChange(of: selectedPhoto) {
                        Task {
                            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                imageCaptured = image
                            }
                        }
                    }
                }
                if let imageCaptured = imageCaptured {
                    Image(uiImage: imageCaptured)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                    
                    Button("Remove Photo") {
                        self.imageCaptured = nil
                    }
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                }
            }
            
            //How are you feeling right now?
            VStack(alignment: .leading, spacing: 10) {
                Text("How are you feeling right now?").font(AppFonts.subhead)
                
                    HStack(spacing: 8) {
                        ForEach(moods, id: \.imageName) { mood in
                            moodButton(mood: mood)
                        }
                    }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.8)).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            
            
            // What prompted you to want to purchase this item?
            VStack(alignment: .leading, spacing: 6){
                Text("What prompted you to want to purchase this item?").font(AppFonts.subhead)
                TextField("Add Note...", text: $itemName).textFieldStyle(.roundedBorder).background(Color.gray)
            }
            
            HStack {
                Spacer()
                Button {
                    showTimerSheet = true
                    // pressedAddItemButton function :P
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        .sheet(isPresented: $showTimerSheet) {
            TimerPauseSheetView().presentationDetents([.fraction(0.65)]).presentationDragIndicator(.visible).presentationCornerRadius(24)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(capturedImage: $imageCaptured, isPresented: $showCamera)
        }
    }
}



#Preview {
    AddItemLogView()
}



