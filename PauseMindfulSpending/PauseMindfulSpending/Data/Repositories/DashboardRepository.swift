import Foundation
import FirebaseFirestore

class DashboardRepository {

    private let firestoreService = FireStoreService()
    private let dashboardConfigKey = "dashboard_config"
    private let db = Firestore.firestore()

    // Fetch the users categories
    func fetchCategoryNames(uid: String, completion: @escaping ([String]) -> Void) {
        firestoreService.fetchCategoryList(uid: uid) { categoryIds in
            guard !categoryIds.isEmpty else {
                completion([])
                return
            }

            let group = DispatchGroup()
            var namesByIndex = Array<String?>(repeating: nil, count: categoryIds.count)

            for (index, categoryId) in categoryIds.enumerated() {
                group.enter()

                self.firestoreService.fetchCategoryStringUsingId(uid: uid, categoryId: categoryId) { categoryName in
                    namesByIndex[index] = categoryName
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(namesByIndex.compactMap { $0 })
            }
        }
    }

    // Saves dashboard configuration locally
    func saveLocalDashboardConfig(_ config: DashboardConfig) {
        guard let encoded = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(encoded, forKey: dashboardConfigKey)
    }

    func loadLocalDashboardConfig() -> DashboardConfig {
        guard let data = UserDefaults.standard.data(forKey: dashboardConfigKey),
              let decoded = try? JSONDecoder().decode(DashboardConfig.self, from: data) else {
            return .empty
        }

        return decoded
    }

    // Fetch the impulses resisted state to be displayed
    func fetchImpulsesState(
        uid: String,
        completion: @escaping (ImpulsesState) -> Void
    ) {
        let service = FireStoreService()

        service.fetchUserDocumentField(uid: uid, fieldName: "impulseResisted") { (resistedCount: Int?) in
            
            let resisted = resistedCount ?? 0
            
            service.db.collection("users")
                .document(uid)
                .collection("items")
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("Failed to fetch items for impulses state:", error.localizedDescription)
                        completion(
                            ImpulsesState(
                                resistedCount: resisted,
                                boughtCount: 0
                            )
                        )
                        return
                    }

                    let documents = snapshot?.documents ?? []
                    var boughtCount = 0

                    for document in documents {
                        let data = document.data()
                        let status = (data["status"] as? String ?? "").lowercased()

                        if status == "item_bought" {
                            boughtCount += 1
                        }
                    }

                    completion(
                        ImpulsesState(
                            resistedCount: resisted,
                            boughtCount: boughtCount
                        )
                    )
                }
        }
    }

    // Fetch the money saved data for data points to be displayed
    func fetchMoneySavedState(
        uid: String,
        completion: @escaping (MoneySavedState) -> Void
    ) {
        let service = FireStoreService()

        service.fetchEventList(uid: uid) { eventIds in
            guard !eventIds.isEmpty else {
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

            let group = DispatchGroup()
            var events: [DashboardEvent] = []

            for eventId in eventIds {
                group.enter()

                service.fetchDocumentFromSubcollection(
                    parentCollection: "users",
                    parentId: uid,
                    subCollection: "events",
                    subId: eventId
                ) { eventData in
                    guard
                        let eventData = eventData,
                        let type = eventData["type"] as? String,
                        let timestamp = eventData["createdAt"] as? Timestamp
                    else {
                        group.leave()
                        return
                    }

                    service.fetchDetailsFromEvent(uid: uid, eventId: eventId) { details in
                        let event = DashboardEvent(
                            id: eventId,
                            type: type,
                            createdAt: timestamp.dateValue(),
                            itemId: details?["itemId"] as? String,
                            timerId: details?["timerId"] as? String,
                            category: details?["categoryId"] as? String,
                            amount: details?["amount"] as? Double,
                            currencyCode: nil
                        )

                        events.append(event)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                let state = MoneySavedCalculator.makeMoneySavedState(
                    from: events.sorted { $0.createdAt < $1.createdAt },
                    currencySymbol: "$"
                )

                completion(state)
            }
        }
    }

    // Fetch streak state for pause streak display
    func fetchStreakState(
        uid: String,
        completion: @escaping (DashboardStreakState) -> Void
    ) {
        let categoriesRef = db.collection("users").document(uid).collection("categories")
        let itemsRef = db.collection("users").document(uid).collection("items")
        let eventsRef = db.collection("users").document(uid).collection("events")

        let group = DispatchGroup()

        var categoryDocs: [QueryDocumentSnapshot] = []
        var itemDocs: [QueryDocumentSnapshot] = []
        var eventDocs: [QueryDocumentSnapshot] = []

        var categoriesError: Error?
        var itemsError: Error?
        var eventsError: Error?

        group.enter()
        categoriesRef.getDocuments { snapshot, error in
            categoriesError = error
            categoryDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.enter()
        itemsRef.getDocuments { snapshot, error in
            itemsError = error
            itemDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.enter()
        eventsRef.order(by: "createdAt", descending: false).getDocuments { snapshot, error in
            eventsError = error
            eventDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.notify(queue: .main) {
            if let categoriesError = categoriesError {
                print("Failed to fetch categories for streak state:", categoriesError.localizedDescription)
            }
            if let itemsError = itemsError {
                print("Failed to fetch items for streak state:", itemsError.localizedDescription)
            }
            if let eventsError = eventsError {
                print("Failed to fetch events for streak state:", eventsError.localizedDescription)
            }

            guard categoriesError == nil, itemsError == nil, eventsError == nil else {
                completion(.empty)
                return
            }

            let categories = categoryDocs.compactMap { PauseStreaksCalculator.makeCategoryRecord(from: $0) }
            let items = itemDocs.map { PauseStreaksCalculator.makeItemRecord(from: $0) }
            let boughtEvents = eventDocs.compactMap { PauseStreaksCalculator.makeBoughtEventRecord(from: $0) }

            let state = PauseStreaksCalculator.makeStreakState(
                categories: categories,
                items: items,
                boughtEvents: boughtEvents
            )

            completion(state)
        }
    }
}
