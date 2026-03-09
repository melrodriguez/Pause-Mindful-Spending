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

    private let repo = DashboardRepository()

    init() {
        self.dashboardConfig = repo.loadLocalDashboardConfig()
    }

    func loadCategories(uid: String) {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
        }
    }

    func saveDashboardConfig(_ config: DashboardConfig) {
        dashboardConfig = config
        repo.saveLocalDashboardConfig(config)
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
}
