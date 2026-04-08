import SwiftUI
import PhotosUI
import AVFoundation

struct AddItemLogView: View {
    
    @EnvironmentObject var session: AppSessionViewModel
    
    var moods: [(imageName: String, label: String)] = [
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

    @State private var isCategoryExpanded: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showCamera: Bool = false
    @State private var permissionDenied: Bool = false
    @State private var showAdjustTimer: Bool = false

    private let defaultSeconds: Int = 24 * 86400
    @State private var timerSeconds: Int = 24 * 86400

    var itemLogged: () -> Void = {}

    private var isFormValid: Bool {
        !vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.selectedMood != nil
    }

    // MARK: - Timer display

    private var timerDisplay: String {
        let days = timerSeconds / 86400
        let hours = (timerSeconds % 86400) / 3600
        let minutes = (timerSeconds % 3600) / 60
        return String(format: "%02dd %02dh %02dm", days, hours, minutes)
    }
    
    // MARK: - Shared item pre-fill, SSE

    private func loadSharedItemIfPresent() {
        let defaults = UserDefaults(suiteName: "group.utcs.PauseMindfulSpending")
        
        guard defaults?.bool(forKey: "has_pending_shared_item") == true else { return }

        if let name = defaults?.string(forKey: "shared_item_name") {
            vm.itemName = name
        }
        if let price = defaults?.string(forKey: "shared_item_price") {
            vm.price = price
        }
        if let imageData = defaults?.data(forKey: "shared_item_image"),
           let image = UIImage(data: imageData) {
            vm.imageCaptured = image
        }

        defaults?.removeObject(forKey: "shared_item_name")
        defaults?.removeObject(forKey: "shared_item_price")
        defaults?.removeObject(forKey: "shared_item_image")
        defaults?.removeObject(forKey: "shared_item_url")
        defaults?.set(false, forKey: "has_pending_shared_item")
        defaults?.synchronize()
    }

    // MARK: - Camera

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    showCamera = granted
                    permissionDenied = !granted
                }
            }
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    // MARK: - Subviews

    private func moodButton(mood: (imageName: String, label: String)) -> some View {
        Button {
            vm.selectMood(mood.imageName)
        } label: {
            VStack(spacing: 4) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .background(
                        Circle().fill(vm.selectedMood == mood.imageName ? Color.mainGreen : Color(.systemGray4))
                    )
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
                        Text(vm.selectedCategory ?? "Select Category")
                            .foregroundColor(vm.selectedCategory == nil ? .gray : .primary)
                        Spacer()
                        Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
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
                                Text(category).foregroundColor(Color.primary)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.accentGreen)
                        }
                        Divider().background(Color.black)
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            .cornerRadius(8)
            
            // Edit categories
            if let uid = session.userProfile?.id {
                NavigationLink(destination: CategoriesView(uid: uid, onCategoriesUpdated: {
                        vm.selectedCategory = ""
                        vm.loadCategories(uid: uid)
                })) {
                    Text("Edit Categories")
                        .font(AppFonts.subhead)
                        .foregroundColor(AppColors.mainGreen)
                }
                .padding(.top, 12)
            }
        }
    }

    private var timerField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pause Timer").font(AppFonts.subhead)
            Button {
                showAdjustTimer = true
            } label: {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(AppColors.mainGreen)
                    Text(timerDisplay)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                    Spacer()
                    if timerSeconds != defaultSeconds {
                        Text("Edited")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.mainGreen)
                    } else {
                        Text("Suggested")
                            .font(AppFonts.caption)
                            .foregroundColor(.gray)
                    }
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(Color.backgroundFill)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Divider()

                    // Item name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Item Name").font(AppFonts.subhead)
                        TextField("E.g. Iced Latte", text: $vm.itemName)
                            .padding(10)
                            .background(Color.backgroundFill)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .foregroundColor(.logText)
                    }

                    // Category
                    categorySection()

                    // Price
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Enter Price").font(AppFonts.subhead)
                        TextField("$0.00", text: $vm.price)
                            .padding(10)
                            .background(Color.backgroundFill)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .foregroundColor(.logText)
                    }

                    // Timer
                    timerField

                    // Photo
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
                            .onChange(of: selectedPhoto) {
                                Task {
                                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
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

                    // Mood
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How are you feeling right now?").font(AppFonts.subhead)
                        HStack(spacing: 8) {
                            ForEach(moods, id: \.imageName) { mood in
                                moodButton(mood: mood)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundFill)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What prompted you to want to purchase this item?").font(AppFonts.subhead)
                        TextField("Add Note...", text: $vm.note)
                            .padding(10)
                            .background(Color.backgroundFill)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .foregroundColor(.logText)
                    }

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Submit button
            Button {
                if isFormValid {
                    vm.createItem(durationSeconds: timerSeconds)
                    itemLogged()
                    dismiss()
                } else {
                    vm.showValidationAlert = true
                }
            } label: {
                Text("Start My Pause")
                    .font(AppFonts.subhead)
                    .fontWeight(.semibold)
                    .foregroundColor(isFormValid ? .white : AppColors.mainGreen)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(isFormValid ? AppColors.mainGreen : AppColors.accentGreen)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.mainGreen, lineWidth: 1.5)
                    )
                    .shadow(
                        color: isFormValid ? AppColors.mainGreen.opacity(0.4) : .clear,
                        radius: 10, x: 0, y: 4
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .onAppear {
            guard let uid = session.userProfile?.id else { return }
            vm.loadCategories(uid: uid)
            loadSharedItemIfPresent()
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .appBackground()
        .sheet(isPresented: $showAdjustTimer) {
            AdjustTimerSheetView(onConfirm: { seconds in
                timerSeconds = seconds
            })
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(capturedImage: $vm.imageCaptured, isPresented: $showCamera)
        }
        .alert("Camera Access Denied", isPresented: $permissionDenied) {
            Button("Open Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to take a photo")
        }
        .alert("Missing Information", isPresented: $vm.showValidationAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("Please fill in your item name, price, and mood before proceeding.")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    AddItemLogView()
}
