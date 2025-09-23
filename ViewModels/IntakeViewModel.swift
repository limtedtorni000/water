import Foundation
import Combine
import CoreData
import SwiftUI

class IntakeViewModel: ObservableObject {
    @Published var todayEntries: [IntakeEntry] = []
    @Published var waterProgress: Double = 0
    @Published var caffeineProgress: Double = 0
    @Published var waterGoal: Double = 2000
    @Published var caffeineGoal: Double = 400
    @Published var waterUnit: String = "ml"
    @Published var caffeineUnit: String = "mg"
    
    private let storageService = StorageService.shared
    private let userDefaults = UserDefaults.standard
    
    private var waterGoalKey = "waterGoal"
    private var caffeineGoalKey = "caffeineGoal"
    private var waterUnitKey = "waterUnit"
    private var caffeineUnitKey = "caffeineUnit"
    
    static let shared = IntakeViewModel()
    
    private init() {
        // Load settings from UserDefaults
        waterGoal = userDefaults.double(forKey: waterGoalKey) == 0 ? 2000 : userDefaults.double(forKey: waterGoalKey)
        caffeineGoal = userDefaults.double(forKey: caffeineGoalKey) == 0 ? 400 : userDefaults.double(forKey: caffeineGoalKey)
        waterUnit = userDefaults.string(forKey: waterUnitKey) ?? "ml"
        caffeineUnit = userDefaults.string(forKey: caffeineUnitKey) ?? "mg"
        
        loadTodayEntries()
    }
    
    var waterGoalValue: Double {
        get {
            return waterGoal
        }
        set {
            waterGoal = newValue
            userDefaults.set(newValue, forKey: waterGoalKey)
            updateProgress()
        }
    }
    
    var caffeineGoalValue: Double {
        get {
            return caffeineGoal
        }
        set {
            caffeineGoal = newValue
            userDefaults.set(newValue, forKey: caffeineGoalKey)
            updateProgress()
        }
    }
    
    var waterUnitValue: String {
        get {
            return waterUnit
        }
        set {
            waterUnit = newValue
            userDefaults.set(newValue, forKey: waterUnitKey)
        }
    }
    
    var caffeineUnitValue: String {
        get {
            return caffeineUnit
        }
        set {
            caffeineUnit = newValue
            userDefaults.set(newValue, forKey: caffeineUnitKey)
        }
    }
    
    func loadTodayEntries() {
        todayEntries = storageService.fetchEntries(for: Date())
        updateProgress()
    }
    
    func addIntake(type: IntakeType, amount: Double) {
        storageService.addIntake(type: type, amount: amount)
        loadTodayEntries()
    }
    
    func deleteEntry(_ entry: IntakeEntry) {
        storageService.deleteEntry(entry)
        loadTodayEntries()
    }
    
    private func updateProgress() {
        let waterTotal = todayEntries
            .filter { storageService.getIntakeType(for: $0) == .water }
            .reduce(0) { $0 + $1.amount }
        
        let caffeineTotal = todayEntries
            .filter { storageService.getIntakeType(for: $0) == .caffeine }
            .reduce(0) { $0 + $1.amount }
        
        waterProgress = min(waterTotal / waterGoal, 1.0)
        caffeineProgress = min(caffeineTotal / caffeineGoal, 1.0)
    }
    
    func waterAmount(for unit: String) -> Double {
        guard waterUnit != unit else { return waterGoal }
        
        if waterUnit == "ml" && unit == "oz" {
            return waterGoal / 29.5735
        } else if waterUnit == "oz" && unit == "ml" {
            return waterGoal * 29.5735
        }
        
        return waterGoal
    }
    
    func caffeineAmount(for unit: String) -> Double {
        guard caffeineUnit != unit else { return caffeineGoal }
        
        if caffeineUnit == "mg" && unit == "cups" {
            return caffeineGoal / 95
        } else if caffeineUnit == "cups" && unit == "mg" {
            return caffeineGoal * 95
        }
        
        return caffeineGoal
    }
}