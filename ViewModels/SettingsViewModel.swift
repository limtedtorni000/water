import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var waterGoal: Double = 2000
    @Published var caffeineGoal: Double = 400
    @Published var waterUnit: String = "ml"
    @Published var caffeineUnit: String = "mg"
    @Published var reminderEnabled: Bool = false
    @Published var reminderInterval: Int = 60
    @Published var reminderType: IntakeType = .both
    
    private let userDefaults = UserDefaults.standard
    private let intakeViewModel: IntakeViewModel
    
    init(intakeViewModel: IntakeViewModel) {
        self.intakeViewModel = intakeViewModel
        loadSettings()
    }
    
    private func loadSettings() {
        // Load from IntakeViewModel (which already handles UserDefaults)
        waterGoal = intakeViewModel.waterGoal
        caffeineGoal = intakeViewModel.caffeineGoal
        waterUnit = intakeViewModel.waterUnit
        caffeineUnit = intakeViewModel.caffeineUnit
        reminderEnabled = userDefaults.bool(forKey: "reminderEnabled")
        reminderInterval = userDefaults.integer(forKey: "reminderInterval") == 0 ? 60 : userDefaults.integer(forKey: "reminderInterval")
        if let reminderTypeString = userDefaults.string(forKey: "reminderType"),
           let savedType = IntakeType(rawValue: reminderTypeString) {
            reminderType = savedType
        }
    }
    
    func saveSettings() {
        // Save to IntakeViewModel (which handles UserDefaults)
        intakeViewModel.waterGoalValue = waterGoal
        intakeViewModel.caffeineGoalValue = caffeineGoal
        intakeViewModel.waterUnitValue = waterUnit
        intakeViewModel.caffeineUnitValue = caffeineUnit
        
        // Save reminder settings to UserDefaults
        userDefaults.set(reminderEnabled, forKey: "reminderEnabled")
        userDefaults.set(reminderInterval, forKey: "reminderInterval")
        userDefaults.set(reminderType.rawValue, forKey: "reminderType")
    }
    
    func resetToDefaults() {
        waterGoal = 2000
        caffeineGoal = 400
        waterUnit = "ml"
        caffeineUnit = "mg"
        reminderEnabled = false
        reminderInterval = 60
        reminderType = .both
        saveSettings()
    }
}