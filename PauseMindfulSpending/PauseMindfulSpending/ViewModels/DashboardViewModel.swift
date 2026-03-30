import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {

    @Published var categories: [String] = []
    @Published var dashboardConfig: DashboardConfig
    @Published var impulsesState = ImpulsesState(
        resistedCount: 0,
        boughtCount: 0
    )
    @Published var moneySavedState = MoneySavedState(
        currencySymbol: "$",
        weeklyData: [],
        monthlyData: [],
        allTimeData: []
    )
    @Published var streakState: DashboardStreakState = .empty
    @Published var activityCalendarData: [String: Int] = [:]
    @Published var budgetState: BudgetState = .empty

    let repo = DashboardRepository()

    init() {
        self.dashboardConfig = .empty
    }
    
    func loadCategories(uid: String, completion: (() -> Void)? = nil) {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
            completion?()
        }
    }

    func saveDashboardConfig(_ config: DashboardConfig, uid: String) {
        dashboardConfig = config
        repo.saveLocalDashboardConfig(config, uid: uid)
    }
    
    func loadImpulsesState(uid: String) {
        repo.fetchImpulsesState(uid: uid) { [weak self] state in
            self?.impulsesState = state
        }
    }
    
    func loadMoneySavedState(uid: String) {
        repo.fetchMoneySavedState(uid: uid) { [weak self] state in
            self?.moneySavedState = state
        }
    }
    
    func loadStreakState(uid: String) {
        repo.fetchStreakState(uid: uid) { [weak self] state in
            self?.streakState = state
        }
    }
    
    func loadActivityCalendarData(uid: String) {
        repo.fetchActivityCalendarState(uid: uid) { [weak self] data in
            self?.activityCalendarData = data
        }
    }

    func loadBudgetState(uid: String) {
        let cached = repo.loadCachedBudgetConfig(uid: uid)
        if !cached.isEmpty {
            budgetState = BudgetState(categories: cached, currencySymbol: "$")
        }

        repo.fetchBudgetState(uid: uid) { [weak self] state in
            self?.budgetState = state
        }
    }

    func saveBudgetCategories(_ budgets: [BudgetCategory], uid: String) {
        let previous = budgetState.categories
        repo.saveBudgetConfig(uid: uid, budgets: budgets, previousBudgets: previous) { [weak self] success in
            guard success else { return }
            self?.loadBudgetState(uid: uid)
        }
    }
    
    func loadConfig(uid: String) {
        dashboardConfig = repo.loadLocalDashboardConfig(uid: uid)
    }
}
