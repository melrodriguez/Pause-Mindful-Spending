import Foundation
import FirebaseFirestore

struct TimerItem: Identifiable, Codable {
    @DocumentID var id: String?
    var itemName: String
    var endDate: Timestamp
    var imageUrl: String?
}
