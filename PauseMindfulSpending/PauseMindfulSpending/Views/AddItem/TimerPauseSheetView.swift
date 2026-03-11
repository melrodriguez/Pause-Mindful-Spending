import SwiftUI

struct TimerPauseSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAdjustTimer: Bool = false
    var onSetTimer: (Int) -> Void = { _ in }
    @State private var adjustedSeconds: Int? = nil
    
    let suggestedDays: Int = 24
    let suggestedHours: Int = 0
    let suggestedMinutes: Int = 0
    
    var suggestedSeconds: Int {
        (suggestedDays*86400)+(suggestedHours*3600)+(suggestedMinutes*60)
    }
    
    var activeSeconds: Int {
        adjustedSeconds ?? suggestedSeconds
    }
    
    var timerDisplay: String {
        let days = activeSeconds/86400
        let hours = (activeSeconds%86400) / 3600
        let minutes = (activeSeconds%3600) / 60
        return String(format: "%02dd %02dh %02dm", days, hours, minutes)
    }
    var body: some View {
        ZStack {
            LinearGradient.timerGradient.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Let's take a moment to pause...").font(AppFonts.headline).multilineTextAlignment(.center).padding(.horizontal)
                
                Text("We'll check back after the time feels right.").font(AppFonts.subhead).multilineTextAlignment(.center).foregroundColor(.gray).padding(.horizontal)
                
                Text(adjustedSeconds == nil ? "Suggested Pause" : "Adjusted Pause").font(.system(size: 24, weight: .semibold))
                
                Text(timerDisplay).font(.system(size: 32, weight: .medium)).frame(maxWidth: .infinity).padding(20).background(Color.backgroundFill).cornerRadius(12).padding(.horizontal)
                
                Button {
                    showAdjustTimer = true
                } label: {
                    Text("Adjust Timer").foregroundColor(.white).frame(maxWidth: .infinity).padding(14).background(Color.mainGreen).cornerRadius(24)
                }.padding(.horizontal)
                
                Button {
                    onSetTimer(suggestedSeconds)
                    dismiss()
                } label: {
                    Text("Set Timer").foregroundColor(.white).frame(maxWidth: .infinity).padding(14).background(Color.mainGreen).cornerRadius(24)
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            }
            .sheet(isPresented: $showAdjustTimer) {
                AdjustTimerSheetView(onConfirm: { seconds in
                    adjustedSeconds = seconds
                }).presentationDetents([.fraction(0.65)]).presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    TimerPauseSheetView(onSetTimer: { seconds in
        print("Timer set for \(seconds) seconds")})
}
