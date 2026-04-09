import SwiftUI
import PhotosUI
import AVFoundation

struct EditItemLogView: View {
    let item: Item
    @Binding var showEditItemLog: Bool
    @ObservedObject var vm: ItemLogViewModel
    @EnvironmentObject var session: AppSessionViewModel

    var editItem: () -> Void

    init(item: Item, showEditItemLog: Binding<Bool>, vm: ItemLogViewModel, editItem: @escaping () -> Void) {
        self.item = item
        self._showEditItemLog = showEditItemLog
        self.vm = vm
        self.editItem = editItem
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

    @State private var showValidationAlert: Bool = false
    @Environment(\.dismiss) var dismiss

    @State private var isCategoryExpanded: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showCamera: Bool = false
    @State private var permissionDenied: Bool = false
    @State private var showAdjustTimer: Bool = false
    @State private var didSave: Bool = false
    @State private var displayedPhoto: UIImage? = nil

    private var isFormValid: Bool {
        vm.updateIsValid(name: vm.name, cost: vm.cost ?? 0, timer: vm.timerSeconds)
    }

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
                    .overlay(
                        Circle()
                            .stroke(Color.mainGreen, lineWidth: 2.5)
                            .opacity(vm.mood == mood.imageName ? 1: 0)
                        )
                    .scaleEffect(vm.mood == mood.imageName ? 1.15 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: vm.mood)
                
                Text(mood.label).font(.system(size: 10)).foregroundColor(.primary)
            }
        }
    }

    private var divider: some View {
        Divider()
            .frame(height: 0.3)
            .background(Color.black)
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
                        Image(systemName: isCategoryExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(Color.backgroundFill)
                }

                if isCategoryExpanded {
                    ForEach(vm.categories, id: \.self) { category in
                        Button {
                            vm.categoryName = category
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
                        divider
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            .cornerRadius(8)

            if let uid = session.userProfile?.id {
                NavigationLink(destination: CategoriesView(uid: uid, onCategoriesUpdated: {
                    vm.categoryName = ""
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

    private func itemNameSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Item Name").font(AppFonts.subhead)
            TextField("E.g. Iced Latte", text: $vm.name)
                .padding(10)
                .background(Color.backgroundFill)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                .foregroundColor(.logText)
        }
    }

    private func priceSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Enter Price").font(AppFonts.subhead)
            TextField("$0.00", value: $vm.cost, format: .currency(code: vm.currencyCode))
                .padding(10)
                .background(Color.backgroundFill)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                .foregroundColor(.logText)
        }
    }

    private func photoSection() -> some View {
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

            if let image = displayedPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
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

    private var timerField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pause Timer").font(AppFonts.subhead)
            Button {
                showAdjustTimer = true
            } label: {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(AppColors.mainGreen)
                    Text(vm.formattedTimer)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                    Spacer()
                    if vm.timerUpdated == true {
                        Text("Edited")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.mainGreen)
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

    private func noteSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What prompted you to want to purchase this item?").font(AppFonts.subhead)
            TextField("Add Note...", text: $vm.notes)
                .padding(10)
                .background(Color.backgroundFill)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                .foregroundColor(.logText)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // Scrollable form
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    itemNameSection()
                    categorySection()
                    priceSection()
                    photoSection()
                    moodSection()
                    timerField
                    noteSection()

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }

            Button {
                if isFormValid {
                    didSave = true
                    editItem()
                    dismiss()
                } else {
                    showValidationAlert = true
                }
            } label: {
                Text("Save Changes")
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
                        color: isFormValid ? AppColors.mainGreen.opacity(0.4) : AppColors.accentGreen.opacity(0.4),
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
            vm.loadItem(uid: uid)
        }
        .onChange(of: selectedPhoto) {
            guard let newItem = selectedPhoto else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let uid = session.userProfile?.id {
                    displayedPhoto = uiImage
                    vm.uploadPhoto(uid: uid, image: uiImage)
                }
            }
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please make sure your item name, price, and pause timer is filled out")
        }
        .sheet(isPresented: $showAdjustTimer) {
            AdjustTimerSheetView(onConfirm: { seconds in
                vm.timerSeconds = seconds
                vm.timerUpdated = true
            })
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
        .navigationTitle("Edit Item")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.timerUpdated = false
        }
        .appBackground()
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    // EditItemLogView()
}
