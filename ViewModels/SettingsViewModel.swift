import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var waterGoal: Double = 2000
    @Published var caffeineGoal: Double = 400
    @Published var waterUnit: String = "ml"
    @Published var caffeineUnit: String = "mg"
    @Published var reminderEnabled: Bool = false
    @Published var reminderInterval: Int = 60
    
    private let userDefaults = UserDefaults.standard
    private let intakeViewModel: IntakeViewModel
    
    init(intakeViewModel: IntakeViewModel) {
        self.intakeViewModel = intakeViewModel
        loadSettings()
    }
    
    private func loadSettings() {
        waterGoal = intakeViewModel.waterGoal
        caffeineGoal = intakeViewModel.caffeineGoal
        waterUnit = intakeViewModel.waterUnit
        caffeineUnit = intakeViewModel.caffeineUnit
        reminderEnabled = userDefaults.bool(forKey: "reminderEnabled")
        reminderInterval = userDefaults.integer(forKey: "reminderInterval") == 0 ? 60 : userDefaults.integer(forKey: "reminderInterval")
    }
    
    func saveSettings() {
        
        intakeViewModel.waterGoal = waterGoal
        intakeViewModel.caffeineGoal = caffeineGoal
        intakeViewModel.waterUnit = waterUnit
        intakeViewModel.caffeineUnit = caffeineUnit
        userDefaults.set(reminderEnabled, forKey: "reminderEnabled")
        userDefaults.set(reminderInterval, forKey: "reminderInterval")
    }
    
    func resetToDefaults() {
        waterGoal = 2000
        caffeineGoal = 400
        waterUnit = "ml"
        caffeineUnit = "mg"
        reminderEnabled = false
        reminderInterval = 60
        saveSettings()
    }
}