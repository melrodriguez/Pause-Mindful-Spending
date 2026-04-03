import Foundation

// A single purchase that counts against a budget category
struct BudgetPurchase: Identifiable, Equatable {
    let id: String
    let itemName: String
    let amount: Double
    let date: Date
}

// A single budget category entry
struct BudgetCategory: Identifiable, Codable, Equatable {
    var id: String
    var limit: Double
    var spent: Double
    var purchases: [BudgetPurchase]
 
    var remaining: Double { max(limit - spent, 0) }
    var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
    var isOverBudget: Bool { spent > limit }
 
    enum CodingKeys: String, CodingKey {
        case id, limit
    }
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        limit = try container.decode(Double.self, forKey: .limit)
        spent = 0
        purchases = []
    }
 
    init(id: String, limit: Double, spent: Double = 0, purchases: [BudgetPurchase] = []) {
        self.id = id
        self.limit = limit
        self.spent = spent
        self.purchases = purchases
    }
 
    static func == (lhs: BudgetCategory, rhs: BudgetCategory) -> Bool {
        lhs.id == rhs.id && lhs.limit == rhs.limit && lhs.spent == rhs.spent
    }
}

// The full state passed into BudgetWidgetView
struct BudgetState {
    var categories: [BudgetCategory]
    var currencySymbol: String
    static let empty = BudgetState(categories: [], currencySymbol: "$")
}
