import SwiftUI

struct AdjustTimerSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var input: String = ""
    var onConfirm: (Int) -> Void = { _ in }
    
    
    var days: String {
        input.count >= 3 ? String(input.prefix(input.count - 2)) : "00"
    }
    var hours: String {
        input.count >= 2 ? String(input.suffix(min(input.count, 2)).prefix(1)) : "00"
    }
    var minutes: String {
        input.count >= 1 ? String(input.suffix(1)) : "00"
    }
    
    var totalSeconds: Int {
        let d = Int(days) ?? 0
        let h = Int(hours) ?? 0
        let m = Int(minutes) ?? 0
        return (d*86400) + (h*3600) + (m*60)
    }
    
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["00", "0", "⌫"]
    ]
    
    var body: some View {
        ZStack {
            LinearGradient.timerGradient.ignoresSafeArea()
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Image("AppLogo")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                
                Text("Set Timer")
                    .font(AppFonts.headline)
                
                Text("\(days)d \(hours)h \(minutes)m")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 16) {
                            ForEach(row, id: \.self) { button in
                                numberButton(button)
                            }
                        }
                    }
                }
                
                Button {
                    onConfirm(totalSeconds)
                    dismiss()
                } label: {
                    Text("Set Timer")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.mainGreen)
                        .cornerRadius(24)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
    
    private func numberButton(_ value: String) -> some View {
        Button {
            handleInput(value)
        } label: {
            Text(value)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 64, height: 64)
                .background(Color.mainPink)
                .clipShape(Circle())
        }
        .foregroundColor(.primary)
    }
    
    private func handleInput(_ value: String) {
        if value == "⌫" {
            if !input.isEmpty { input.removeLast() }
        } else {
            if input.count < 6 {
                input += value
            }
        }
    }
}

#Preview {
    AdjustTimerSheetView(onConfirm: { seconds in
        print("Confirmed: \(seconds) seconds")
    })
}


