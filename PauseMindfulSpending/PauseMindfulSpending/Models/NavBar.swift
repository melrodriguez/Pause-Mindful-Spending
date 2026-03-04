import Foundation

enum NavBar: String, CaseIterable, Identifiable {
    case home = "Home"
    case timers = "Timers"
    case wishlist = "Wishlist"
    case settings = "Settings"

    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .timers:
            return "clock.fill"
        case .wishlist:
            return "heart.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}
