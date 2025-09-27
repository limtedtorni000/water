import Foundation

// MARK: - Widget Data Models (Main App)
struct HydrationData: Codable {
    let currentWater: Double
    let waterGoal: Double
    let currentCaffeine: Double
    let caffeineGoal: Double
    let waterUnit: String
    let caffeineUnit: String
    let lastUpdated: Date
    let entries: [WidgetIntakeEntry]
    
    var waterProgress: Double {
        guard waterGoal > 0 else { return 0 }
        return min(currentWater / waterGoal, 1.0)
    }
    
    var caffeineProgress: Double {
        guard caffeineGoal > 0 else { return 0 }
        return min(currentCaffeine / caffeineGoal, 1.0)
    }
}

struct WidgetIntakeEntry: Codable {
    let amount: Double
    let type: String
    let date: Date
}

struct WeeklyAnalytics: Codable {
    let weekData: [DayData]
    let averageWater: Double
    let averageCaffeine: Double
    let trend: TrendDirection
    
    enum TrendDirection: String, Codable {
        case up = "up"
        case down = "down"
        case stable = "stable"
    }
}

struct DayData: Codable {
    let date: Date
    let waterIntake: Double
    let caffeineIntake: Double
    let goalReached: Bool
}

// MARK: - Widget Data Manager (Main App)
class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let appGroup = "group.hydratrack"
    
    private init() {}
    
    // UserDefaults keys
    private enum Keys {
        static let hydrationData = "hydrationData"
        static let weeklyAnalytics = "weeklyAnalytics"
        static let lastDataUpdate = "lastDataUpdate"
    }
    
    // Shared container
    private var sharedDefaults: UserDefaults {
        return UserDefaults(suiteName: appGroup)!
    }
    
    // Save hydration data
    func saveHydrationData(_ data: HydrationData) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            sharedDefaults.set(encodedData, forKey: Keys.hydrationData)
            sharedDefaults.set(Date(), forKey: Keys.lastDataUpdate)
        } catch {
            print("Error saving hydration data: \(error)")
        }
    }
    
    // Load hydration data
    func loadHydrationData() -> HydrationData? {
        guard let data = sharedDefaults.data(forKey: Keys.hydrationData) else { return nil }
        
        do {
            let hydrationData = try JSONDecoder().decode(HydrationData.self, from: data)
            return hydrationData
        } catch {
            print("Error loading hydration data: \(error)")
            return nil
        }
    }
    
    // Save weekly analytics
    func saveWeeklyAnalytics(_ analytics: WeeklyAnalytics) {
        do {
            let encodedData = try JSONEncoder().encode(analytics)
            sharedDefaults.set(encodedData, forKey: Keys.weeklyAnalytics)
        } catch {
            print("Error saving weekly analytics: \(error)")
        }
    }
    
    // Load weekly analytics
    func loadWeeklyAnalytics() -> WeeklyAnalytics? {
        guard let data = sharedDefaults.data(forKey: Keys.weeklyAnalytics) else { return nil }
        
        do {
            let analytics = try JSONDecoder().decode(WeeklyAnalytics.self, from: data)
            return analytics
        } catch {
            print("Error loading weekly analytics: \(error)")
            return nil
        }
    }
    
    // Check if data needs refresh
    func shouldRefreshData() -> Bool {
        guard let lastUpdate = sharedDefaults.object(forKey: Keys.lastDataUpdate) as? Date else {
            return true
        }
        
        // Refresh if data is older than 5 minutes
        return Date().timeIntervalSince(lastUpdate) > 300
    }
    
    // Get user preferences
    func getUserPreferences() -> (waterGoal: Double, caffeineGoal: Double, waterUnit: String, caffeineUnit: String) {
        let defaults = UserDefaults(suiteName: appGroup)!
        
        let waterGoal = defaults.double(forKey: "waterGoal") != 0 ? defaults.double(forKey: "waterGoal") : 2000
        let caffeineGoal = defaults.double(forKey: "caffeineGoal") != 0 ? defaults.double(forKey: "caffeineGoal") : 400
        let waterUnit = defaults.string(forKey: "waterUnit") ?? "ml"
        let caffeineUnit = defaults.string(forKey: "caffeineUnit") ?? "mg"
        
        return (waterGoal, caffeineGoal, waterUnit, caffeineUnit)
    }
}