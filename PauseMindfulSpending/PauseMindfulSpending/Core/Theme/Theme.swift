import SwiftUI

// MARK: - Colors (Asset Colors)
enum AppColors {
    static let mainGreen   = Color("MainGreen")
    static let accentGreen = Color("AccentGreen")
    static let blue        = Color("MainBlue")
    static let pink        = Color("MainPink")

    // Text
    static let textPrimary   = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")

    // Background gradient stops
    static let bg1 = Color("BG1") // #FFF9E5
    static let bg2 = Color("BG2") // #FFFCF2
    static let bg3 = Color("BG3") // #FFFFFF
    
    // Cell Color
    static let ListCell = Color("ListCell")

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: bg1, location: 0.00),
                .init(color: bg2, location: 0.89),
                .init(color: bg3, location: 1.00)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension LinearGradient {
    static var timerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: AppColors.mainGreen, location: 0.00),
                .init(color: AppColors.bg1, location: 1.00)
            ])
            , startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Fonts (Inter)
enum AppFonts {

    static func bold(_ size: CGFloat) -> Font {
        Font.custom("Inter18pt-Bold", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        Font.custom("Inter18pt-SemiBold", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        Font.custom("Inter18pt-Medium", size: size)
    }

    static func regular(_ size: CGFloat) -> Font {
        Font.custom("Inter18pt-Regular", size: size)
    }

    static let title    = bold(28)
    static let headline = semibold(20)
    static let body     = regular(16)
    static let subhead  = medium(14)
    static let caption  = regular(12)
}

// MARK: - Spacing / Corner Radius / Shadows - LATER!!
enum AppLayout {
    static let horizontalScreenPadding: CGFloat = 20
}

// MARK: - Background View Modifier
struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    /// Applies the app’s background gradient behind this view.
    func appBackground() -> some View {
        modifier(AppBackground())
    }

    /// Applies the Inter font style + default text color.
    func appTextStyle(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
