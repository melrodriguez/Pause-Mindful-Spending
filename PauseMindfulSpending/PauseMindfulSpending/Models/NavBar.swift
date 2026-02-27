import Foundation

enum NavBar: String, CaseIterable, Identifiable {
    case home = "Home"
    case timers = "Timers"
    case wishlist = "Wishlist"
    case settings = "Settings"

    var id: String { rawValue }
}
