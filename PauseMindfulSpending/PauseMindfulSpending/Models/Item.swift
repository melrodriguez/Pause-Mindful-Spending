import Foundation
import FirebaseFirestore

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var status: String
    var timerId: String?
    var categoryId: String?
    var imageUrl: String?
}
