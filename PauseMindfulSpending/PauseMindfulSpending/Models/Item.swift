import Foundation

struct Item: Identifiable {
    let id: String
    let name: String
    let timerId: String
    let categoryId: String?
    let imageUrl: String?
}
