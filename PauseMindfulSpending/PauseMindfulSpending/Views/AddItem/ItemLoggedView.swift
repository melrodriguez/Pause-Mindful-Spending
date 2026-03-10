//
//  ItemLoggedView.swift
//  PauseMindfulSpending
//
//  Created by Caballero, Isabella on 3/10/26.
//

import SwiftUI
import ConfettiSwiftUI

struct ItemLoggedView: View {
    
    var onContinue: () -> Void = {}
    
    @State private var confettiCounter: Int = 0
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing : 20) {
                Text("Your Item was Logged!").font(AppFonts.headline).multilineTextAlignment(.center).padding(.top, 20)
                
                ZStack {
                    ForEach(0..<8) { i in
                        Rectangle()
                            .fill(.mainPink)
                            .frame(width: 2, height: 12)
                            .offset(y: -50)
                            .rotationEffect(.degrees(Double(i) * 50))
                    }
                    Circle().fill(Color.mainGreen.opacity(0.4)).frame(width: 90, height: 90)
                    
                    Circle().fill(Color.mainGreen).frame(width: 70, height: 70)
                    
                    Image("AppLogo").resizable().frame(width: 40, height: 40)
                }.frame(height: 120).confettiCannon(trigger: $confettiCounter, colors: [.mainGreen, .pink, .yellow, .blue, .orange], confettiSize: 8, rainHeight: 400, openingAngle: Angle(degrees: 60), closingAngle: Angle(degrees: 120), radius: 200 )

                
                Button {
                    onContinue()
                } label: {
                    Text("Continue to Homepage").font(AppFonts.subhead).foregroundColor(.primary).frame(maxWidth: .infinity).padding(14).background(Color.backgroundFill).cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            background(Color.gray)
                .cornerRadius(24).padding(.horizontal, 40)
        }
        .onAppear {
            confettiCounter += 1
        }
    }
}

#Preview {
    ItemLoggedView(onContinue: {})
}
