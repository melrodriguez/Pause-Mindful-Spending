import Foundation

// A single budget category entry — name, limit, and how much has been spent
struct BudgetCategory: Identifiable, Codable, Equatable {
    var id: String       // matches the category name ("Overall" or a real category)
    var limit: Double    // the user's budget cap
    var spent: Double    // filled in from item_bought events at runtime (not persisted)

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
    }

    init(id: String, limit: Double, spent: Double = 0) {
        self.id = id
        self.limit = limit
        self.spent = spent
    }
}

// The full state passed into BudgetWidgetView
struct BudgetState {
    var categories: [BudgetCategory]
    var currencySymbol: String

    static let empty = BudgetState(categories: [], currencySymbol: "$")
}
