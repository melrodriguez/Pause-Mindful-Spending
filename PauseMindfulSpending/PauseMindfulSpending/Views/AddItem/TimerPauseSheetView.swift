//
//  TimerPause.swift
//  PauseMindfulSpending
//
//  Created by Caballero, Isabella on 3/10/26.
//
import SwiftUI

struct TimerPauseSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAdjustTimer: Bool = false
    
    let suggestedDays: Int = 24
    let suggestedHours: Int = 0
    let suggestedMinutes: Int = 0
    var body: some View {
        VStack(spacing: 20) {
            Text("Let's take a moment to pause...").font(AppFonts.headline).multilineTextAlignment(.center).padding(.horizontal)
            
            Text("We'll check back after the time feels right.").font(AppFonts.subhead).multilineTextAlignment(.center).foregroundColor(.gray).padding(.horizontal)
            
            Text("Suggested Pause").font(.system(size: 24, weight: .semibold))
            
            Text(String(format: "%02dd %02dh %02dm", suggestedDays, suggestedHours, suggestedMinutes)).font(.system(size: 32, weight: .medium)).frame(maxWidth: .infinity).padding(20).background(Color.white).cornerRadius(12).padding(.horizontal)
            
            
            Button {
                showAdjustTimer = true
            } label: {
                Text("Set Timer").foregroundColor(.white).frame(maxWidth: .infinity).padding(14).background(Color.mainGreen).cornerRadius(24)
            }
            .padding(.horizontal)
        }
        .padding(.top, 20).appBackground().sheet(isPresented: $showAdjustTimer) {
            AdjustTimerSheetView().presentationDetents([.fraction(0.65)]).presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    TimerPauseSheetView()
}
