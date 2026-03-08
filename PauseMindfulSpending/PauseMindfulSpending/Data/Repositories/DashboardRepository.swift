import Foundation
import FirebaseFirestore

class DashboardRepository {

    private let firestoreService = FireStoreService()
    private let dashboardConfigKey = "dashboard_config"
    private let db = Firestore.firestore()

    // Fetches user categories from Firestore
    func fetchUserCategories(
        uid: String,
        completion: @escaping ([String]) -> Void
    ) {
        firestoreService.fetchUser(uid: uid) { data in
            let categories = data?["categories"] as? [String] ?? []
            completion(categories)
        }
    }

    // Saves dashboard layout locally
    func saveLocalDashboardConfig(_ config: DashboardConfig) {
        guard let encoded = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(encoded, forKey: dashboardConfigKey)
    }

    // Loads dashboard layout locally
    func loadLocalDashboardConfig() -> DashboardConfig {
        guard let data = UserDefaults.standard.data(forKey: dashboardConfigKey),
              let decoded = try? JSONDecoder().decode(DashboardConfig.self, from: data) else {
            return .empty
        }

        return decoded
    }

    // Fetches all user items and counts wishlist vs bought
    func fetchImpulsesState(
        uid: String,
        completion: @escaping (ImpulsesState) -> Void
    ) {
        db.collection("users")
            .document(uid)
            .collection("items")
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Failed to fetch items for impulses state:", error.localizedDescription)
                    completion(ImpulsesState(resistedCount: 0, boughtCount: 0))
                    return
                }

                let documents = snapshot?.documents ?? []

                var resistedCount = 0
                var boughtCount = 0

                for document in documents {
                    let data = document.data()
                    let status = (data["status"] as? String ?? "").lowercased()

                    if status == "wishlist" {
                        resistedCount += 1
                    } else if status == "bought" {
                        boughtCount += 1
                    }
                }

                completion(
                    ImpulsesState(
                        resistedCount: resistedCount,
                        boughtCount: boughtCount
                    )
                )
            }
    }
    
    // Fetches dashboard events and builds MoneySavedState from them
    func fetchMoneySavedState(
        uid: String,
        completion: @escaping (MoneySavedState) -> Void
    ) {
        db.collection("users")
            .document(uid)
            .collection("events")
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Failed to fetch events for money saved:", error.localizedDescription)
                    completion(
                        MoneySavedState(
                            currencySymbol: "$",
                            weeklyData: [],
                            monthlyData: [],
                            allTimeData: []
                        )
                    )
                    return
                }

                let documents = snapshot?.documents ?? []

                let events: [DashboardEvent] = documents.compactMap { document -> DashboardEvent? in
                    let data = document.data()

                    guard let type = data["type"] as? String else {
                        print("Event missing type:", data)
                        return nil
                    }

                    let createdAt: Date
                    if let timestamp = data["createdAt"] as? Timestamp {
                        createdAt = timestamp.dateValue()
                    } else if let date = data["createdAt"] as? Date {
                        createdAt = date
                    } else {
                        print("Event missing or invalid createdAt:", data)
                        return nil
                    }

                    let amount: Double?
                    if let doubleValue = data["amount"] as? Double {
                        amount = doubleValue
                    } else if let intValue = data["amount"] as? Int {
                        amount = Double(intValue)
                    } else {
                        amount = nil
                    }

                    return DashboardEvent(
                        id: document.documentID,
                        type: type,
                        createdAt: createdAt,
                        itemId: data["itemId"] as? String,
                        timerId: data["timerId"] as? String,
                        category: data["category"] as? String,
                        amount: amount,
                    )
                }

                let state = MoneySavedCalculator.makeMoneySavedState(
                    from: events,
                    currencySymbol: "$"
                )

                completion(state)
            }
    }
}
