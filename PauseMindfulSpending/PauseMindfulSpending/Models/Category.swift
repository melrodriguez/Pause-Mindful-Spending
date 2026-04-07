import Foundation
import FirebaseFirestore

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}
