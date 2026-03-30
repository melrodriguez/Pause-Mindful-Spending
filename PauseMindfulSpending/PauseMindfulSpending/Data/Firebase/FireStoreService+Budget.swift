import FirebaseFirestore

extension FireStoreService {

    // Save all budget categories for a user.
    // Each category gets its own document keyed by categoryId,
    // so individual limits can be updated without rewriting the whole list.
    func saveBudgets(
        uid: String,
        budgets: [BudgetCategory],
        completion: @escaping (Bool) -> Void
    ) {
        let group = DispatchGroup()
        var allSucceeded = true

        for budget in budgets {
            group.enter()
            let data: [String: Any] = [
                "categoryId": budget.id,
                "limit": budget.limit,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            db.collection("users")
                .document(uid)
                .collection("budgets")
                .document(budget.id)
                .setData(data, merge: true) { error in
                    if error != nil { allSucceeded = false }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            completion(allSucceeded)
        }
    }

    // Delete a budget document — called when user removes a category from their budget
    func deleteBudget(uid: String, categoryId: String) {
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .document(categoryId)
            .delete()
    }

    // Fetch all saved budget limits for a user
    func fetchBudgets(
        uid: String,
        completion: @escaping ([BudgetCategory]) -> Void
    ) {
        db.collection("users")
            .document(uid)
            .collection("budgets")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }

                let budgets: [BudgetCategory] = docs.compactMap { doc in
                    let data = doc.data()
                    guard
                        let categoryId = data["categoryId"] as? String,
                        let limit = data["limit"] as? Double
                    else { return nil }

                    return BudgetCategory(id: categoryId, limit: limit, spent: 0)
                }

                completion(budgets)
            }
    }
}
