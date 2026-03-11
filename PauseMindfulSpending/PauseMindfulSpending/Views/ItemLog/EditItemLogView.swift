import SwiftUI
import PhotosUI
import AVFoundation

// Reuse AddItemLog for EditItemLog!
// It's pretty much the same, except I split up everything into sections for the compiler
// TODO: This and AddItemLog should probably be remade into modular components

struct EditItemLogView: View {
    let item: Item
    @Binding var showEditItemLog: Bool
    @ObservedObject var vm: ItemLogViewModel
    @EnvironmentObject var session: AppSessionViewModel
    
    var editItem: () -> Void
    
    // Pass in the parent ItemLogViewModel
    // ItemLogView -> EditItemLog
    init(item: Item, showEditItemLog: Binding<Bool>, vm: ItemLogViewModel, editItem: @escaping () -> Void) {
        self.item = item
        self._showEditItemLog = showEditItemLog
        self.vm = vm
        self.editItem = editItem
    }
    
    var moods : [(imageName: String, label: String)] = [
        ("ExcitedFace", "Excited"),
        ("HappyFace", "Happy"),
        ("CalmFace", "Calm"),
        ("BoredFace", "Bored"),
        ("SadFace", "Sad"),
        ("AnxiousFace", "Anxious"),
        ("StressedFace", "Stressed")
    ]
    
    @State private var showValidationAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @State private var isCategoryExpanded: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showCamera: Bool = false
    @State private var permissionDenied: Bool = false
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    } else {
                        permissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }
    
    private func moodButton(mood: (imageName: String, label: String)) -> some View {
        Button {
            vm.mood = mood.imageName
        } label: {
            VStack(spacing: 4) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .background(Circle()
                        .fill(vm.mood == mood.imageName ? Color.mainGreen : Color(.systemGray4)))
                Text(mood.label).font(.system(size: 10)).foregroundColor(.primary)
            }
        }
    }
    
    private func categorySection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Category").font(AppFonts.subhead)
            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCategoryExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(vm.categoryName ?? "")
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down").foregroundColor(.gray) // fix
                    }
                    .padding(10)
                    .background(Color.backgroundFill)
                }
                
                if isCategoryExpanded {
                    Divider()
                    ForEach(vm.categories, id: \.self) { category in
                        Button {
                            vm.categoryName = category
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isCategoryExpanded = false
                            }
                        } label: {
                            HStack {
                                Text(category).foregroundColor(.black)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.accentGreen)
                        }
                        Divider().background(Color.black)
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
            .cornerRadius(8)
        }
    }
    
    private func itemNameSection() -> some View {
        // Item name input box
        VStack(alignment: .leading, spacing: 6){
            Text("Item Name").font(AppFonts.subhead)
            
            TextField("E.g. Iced Latte", text: $vm.name)
                .padding(10)
                .background(Color.backgroundFill)
                .cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                .foregroundColor(.logText)

        }
    }
    
    private func priceSection() -> some View {
        // Price input box
        VStack(alignment: .leading, spacing: 6){
            Text("Enter Price").font(AppFonts.subhead)
            
            TextField("$0.00", value: $vm.cost, format: .currency(code: vm.currencyCode))
                .padding(10)
                .background(Color.backgroundFill).cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .foregroundColor(.logText))

        }
    }
    
    // Does nothing for now
    // Also took out some alerts/popups from AddItemLog
    private func photoSection() -> some View {
        // Photo gallery and camera section
        VStack(alignment: .leading, spacing: 10) {
            Text("Photo").font(AppFonts.subhead)
            HStack(spacing: 12) {
                
                Button {
                    checkCameraPermission()
                } label: {
                    Label("Take Photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.mainGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("From Gallery", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.mainGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func moodSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How are you feeling right now?").font(AppFonts.subhead)
            
            HStack(spacing: 8) {
                ForEach(moods, id: \.imageName) { mood in
                    moodButton(mood: mood)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6).opacity(0.8))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }
    
    private func noteSection() -> some View {
        // What prompted you to want to purchase this item?
        VStack(alignment: .leading, spacing: 6){
            Text("What prompted you to want to purchase this item?")
                .font(AppFonts.subhead)
            TextField("Add Note...", text: $vm.notes)
                .padding(10).background(Color.backgroundFill)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    .foregroundColor(.logText)
        }
    }
    
    private func saveButton() -> some View {
        VStack {
            Button { // Similar logic from the add button
                let valid = vm.updateIsValid(name: vm.name, cost: vm.cost ?? 0)
                if !valid {
                    showValidationAlert = true
                } else {
                    editItem()
                    // print("pressed the save button")
                }
            } label: {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .font(AppFonts.subhead)
                    .background(AppColors.mainGreen)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Breaking it up
            itemNameSection()
            categorySection()
            priceSection()
            photoSection()
            moodSection()
            noteSection()
            saveButton()
        }
        
        .padding(.horizontal, 20)
        
        .onAppear {
            guard let uid = session.userProfile?.id else { return }
            vm.loadCategories(uid: uid)
            vm.loadItem(uid: uid)
        }
        
        // Original alert, just moved up
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please fill in your item name, category, price, and mood before proceeding.")
        }
        
        .navigationTitle("Edit Item")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        
        // Insert camera alert/popup handling here
    }
}


#Preview {
    // EditItemLogView()
}
