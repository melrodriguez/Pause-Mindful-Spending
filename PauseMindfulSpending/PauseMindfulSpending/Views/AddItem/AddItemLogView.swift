import SwiftUI
import PhotosUI
import AVFoundation

struct AddItemLogView: View {
    
    @EnvironmentObject var session: AppSessionViewModel
    
    var moods : [(imageName: String, label: String)] = [
        ("ExcitedFace", "Excited"),
        ("HappyFace", "Happy"),
        ("CalmFace", "Calm"),
        ("BoredFace", "Bored"),
        ("SadFace", "Sad"),
        ("AnxiousFace", "Anxious"),
        ("StressedFace", "Stressed")
    ]
    
    @StateObject private var vm = AddItemLogViewModel()
    @Environment(\.dismiss) var dismiss
    
//    @State private var itemName: String = ""
//    @State private var selectedCategory: String? = nil
    @State private var isCategoryExpanded: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
//    @State private var imageCaptured: UIImage? = nil
//    @State private var selectedMood: String? = nil
//    @State private var showTimerSheet: Bool = false
    @State private var showCamera: Bool = false
    @State private var permissionDenied: Bool = false
//    @State private var note: String = ""
//    @State private var price: String = ""
//    @State private var showValidationAlert: Bool = false
    
//    var isValid: Bool {
//        !itemName.isEmpty && selectedMood != nil && !price.isEmpty && selectedCategory != nil
//    }
    
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
            vm.selectMood(mood.imageName)
        } label: {
            VStack(spacing: 4) {
                Image(mood.imageName).resizable().scaledToFit().frame(width: 38, height: 38).background(Circle().fill(vm.selectedMood == mood.imageName ? Color.mainGreen : Color(.systemGray4)))
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
                        Text(vm.selectedCategory ?? "Select Category").foregroundColor(vm.selectedCategory == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down").foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(Color.backgroundFill)
                }
                
                if isCategoryExpanded {
                    Divider()
                    ForEach(vm.categories, id: \.self) { category in
                        Button {
                            vm.selectedCategory = category
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
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1)).cornerRadius(8)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Divider()
            
            // bubble for text header
            Text("What item would you like to add?").font(AppFonts.headline).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
            
            // Item name input box
            VStack(alignment: .leading, spacing: 6){
                Text("Item Name").font(AppFonts.subhead)
                TextField("E.g. Iced Latte", text: $vm.itemName).padding(10).background(Color.backgroundFill).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))        .foregroundColor(.logText)

            }
            
            
            // category section of input item
            categorySection()
            
            // text box for price input
            VStack(alignment: .leading, spacing: 6){
                Text("Enter Price").font(AppFonts.subhead)
                TextField("$0.00", text: $vm.price).padding(10).background(Color.backgroundFill).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))        .foregroundColor(.logText)

            }
            
            //photo gallery and camera section
            VStack(alignment: .leading, spacing: 10) {
                Text("Photo").font(AppFonts.subhead)
                HStack(spacing: 12) {
                    
                    Button {
                        checkCameraPermission()
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
                                vm.imageCaptured = image
                            }
                        }
                    }
                }
                if let imageCaptured = vm.imageCaptured {
                    Image(uiImage: imageCaptured)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                    
                    Button("Remove Photo") {
                        vm.removeImage()
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
                TextField("Add Note...", text: $vm.note).padding(10).background(Color.backgroundFill).cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))        .foregroundColor(.logText)

            }
            
            HStack {
                Spacer()
                Button {
                    vm.pressedAddItemButton()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color.backgroundFill)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        
        .onAppear() {
            guard let uid = session.userProfile?.id else { return }
            vm.loadCategories(uid: uid)
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        .sheet(isPresented: $vm.showTimerSheet) {
            TimerPauseSheetView(onSetTimer: { seconds in
                vm.createItem(durationSeconds: seconds)
                vm.showTimerSheet = false
                dismiss()
            }).presentationDetents([.fraction(0.65)]).presentationDragIndicator(.visible).presentationCornerRadius(24)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(capturedImage: $vm.imageCaptured, isPresented: $showCamera)
        }
        .alert("Camera Access Denied", isPresented: $permissionDenied) {
            Button("Open Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) {
            }
        } message: {
            Text("Please enable camera access in Settings to take a photo")
        }
        .alert("Missing Information", isPresented: $vm.showValidationAlert) {
            Button("Ok", role: .cancel) {
            }
        } message: {
            Text("Please fill in your item name, category, price, and mood before proceeding.")
        }
    }
}



#Preview {
    AddItemLogView()
}



