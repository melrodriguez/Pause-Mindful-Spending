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

    private let repo = DashboardRepository()

    init() {
        self.dashboardConfig = repo.loadLocalDashboardConfig()
    }

    // Loads categories from Firestore
    func loadCategories(uid: String) {
        repo.fetchUserCategories(uid: uid) { [weak self] categories in
            self?.categories = categories
            print("Loaded categories:", categories)
        }
    }

    // Saves dashboard config locally and updates UI
    func saveDashboardConfig(_ config: DashboardConfig) {
        dashboardConfig = config
        repo.saveLocalDashboardConfig(config)
    }
    
    // Load impulses resisted state
    func loadImpulsesState(uid: String) {
        repo.fetchImpulsesState(uid: uid) { [weak self] state in
            DispatchQueue.main.async {
                self?.impulsesState = state
            }
        }
    }
    
    
    func loadMoneySavedState(uid: String) {
        repo.fetchMoneySavedState(uid: uid) { [weak self] state in
            DispatchQueue.main.async {
                self?.moneySavedState = state
            }
        }
    }
}
