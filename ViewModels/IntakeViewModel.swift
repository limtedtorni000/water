import Foundation
import Combine
import CoreData
import SwiftUI

class IntakeViewModel: ObservableObject {
    @Published var todayEntries: [IntakeEntry] = []
    @Published var waterProgress: Double = 0
    @Published var caffeineProgress: Double = 0
    
    private let storageService = StorageService.shared
    private let userDefaults = UserDefaults.standard
    
    private var waterGoalKey = "waterGoal"
    private var caffeineGoalKey = "caffeineGoal"
    private var waterUnitKey = "waterUnit"
    private var caffeineUnitKey = "caffeineUnit"
    
    init() {
        loadTodayEntries()
    }
    
    var waterGoal: Double {
        get {
            return userDefaults.double(forKey: waterGoalKey) == 0 ? 2000 : userDefaults.double(forKey: waterGoalKey)
        }
        set {
            userDefaults.set(newValue, forKey: waterGoalKey)
            updateProgress()
        }
    }
    
    var caffeineGoal: Double {
        get {
            return userDefaults.double(forKey: caffeineGoalKey) == 0 ? 400 : userDefaults.double(forKey: caffeineGoalKey)
        }
        set {
            userDefaults.set(newValue, forKey: caffeineGoalKey)
            updateProgress()
        }
    }
    
    var waterUnit: String {
        get {
            return userDefaults.string(forKey: waterUnitKey) ?? "ml"
        }
        set {
            userDefaults.set(newValue, forKey: waterUnitKey)
        }
    }
    
    var caffeineUnit: String {
        get {
            return userDefaults.string(forKey: caffeineUnitKey) ?? "mg"
        }
        set {
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