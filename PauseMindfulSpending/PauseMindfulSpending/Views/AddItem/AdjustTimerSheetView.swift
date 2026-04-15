import SwiftUI

struct AdjustTimerSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var dayInput: String = ""
    @State private var hourInput: String = ""
    @State private var minuteInput: String = ""
    @State private var userClicked: Field = .day
    
    enum Field {
        case day, hour, minute
    }
    
    @State private var input: String = ""
    var initialSeconds: Int = 0
    var onConfirm: (Int) -> Void = { _ in }
    
    var totalSeconds: Int {
        let d = Int(dayInput) ?? 0
        let h = Int(hourInput) ?? 0
        let m = Int(minuteInput) ?? 0
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
                Spacer()
                
                Text("Set Timer")
                    .font(AppFonts.headline)
                    .padding(.top, 20)
                
                HStack(spacing: 12) {
                    fieldBox(label: "Days", value: dayInput, Field: .day)
                    Text(":").font(.system(size: 24, weight: .bold))
                    fieldBox(label: "Hours", value: hourInput, Field: .hour)
                    Text(":").font(.system(size: 24, weight: .bold))
                    fieldBox(label: "Mins", value: minuteInput, Field: .minute)
                }
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
                
                Text(totalSeconds == 0 ? "Please set a timer greater than 0" : " ")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.pink)
                    .padding(.top, 4)
                
                Button {
                    guard totalSeconds > 0 else { return }
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
            .onAppear {
                guard initialSeconds > 0 else { return }
                let d = initialSeconds / 86400
                let h = (initialSeconds % 86400) / 3600
                let m = (initialSeconds % 3600) / 60
                dayInput = d > 0 ? String(d) : ""
                hourInput = h > 0 ? String(h) : ""
                minuteInput = m > 0 ? String(m) : ""
            }
        }
    }
    
    private func fieldBox(label: String, value: String, Field: Field) -> some View {
        VStack(spacing: 4) {
            Text(value.isEmpty ? "00" : value).font(.system(size: 32, weight: .bold)).frame(maxWidth: .infinity).padding(12).background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(userClicked == Field ? 0.8 : 0.4)).overlay(RoundedRectangle(cornerRadius: 12).stroke(userClicked == Field ? Color.mainGreen : Color.clear, lineWidth: 2)))
            Text(label).font(.caption)
        }
        .onTapGesture {
            userClicked = Field
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
        let current: String
        let maxDigits: Int
        let maxValue: Int
        
        switch userClicked {
        case .day:    current = dayInput;    maxDigits = 3; maxValue = 999
        case .hour:   current = hourInput;   maxDigits = 2; maxValue = 23
        case .minute: current = minuteInput; maxDigits = 2; maxValue = 59
        }
        
        if value == "⌫" {
            let trimmed = String(current.dropLast())
            switch userClicked {
            case .day:    dayInput = trimmed
            case .hour:   hourInput = trimmed
            case .minute: minuteInput = trimmed
            }
        } else {
            let newVal = current + value
            if newVal.count <= maxDigits, let num = Int(newVal), num <= maxValue {
                switch userClicked {
                case .day:    dayInput = newVal
                case .hour:   hourInput = newVal
                case .minute: minuteInput = newVal
                }
            }
        }
    }
}


