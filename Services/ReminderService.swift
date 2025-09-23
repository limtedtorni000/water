import Foundation
import UserNotifications

class ReminderService {
    static let shared = ReminderService()
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification authorization granted")
                    // Check if reminders were enabled before and reschedule them
                    let reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
                    if reminderEnabled {
                        let reminderInterval = UserDefaults.standard.integer(forKey: "reminderInterval") == 0 ? 60 : UserDefaults.standard.integer(forKey: "reminderInterval")
                        self.scheduleHydrationReminder(interval: TimeInterval(reminderInterval * 60))
                    }
                } else if let error = error {
                    print("❌ Notification authorization error: \(error)")
                } else {
                    print("❌ Notification authorization denied")
                }
            }
        }
    }
    
    func scheduleHydrationReminder(interval: TimeInterval = 3600) {
        cancelAllReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to hydrate!"
        content.body = "Don't forget to drink some water to stay healthy."
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // Ensure minimum interval is 30 seconds for testing
        let minimumInterval = max(30, interval)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: minimumInterval, repeats: true)
        let request = UNNotificationRequest(identifier: "hydrationReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling reminder: \(error)")
                    // If scheduling failed, clear the saved settings to prevent inconsistent state
                    UserDefaults.standard.set(false, forKey: "reminderEnabled")
                } else {
                    print("✅ Hydration reminder scheduled successfully with interval: \(minimumInterval / 60) minutes")
                }
            }
        }
    }
    
    func getPendingReminders(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                let hydrationReminders = requests.filter { $0.identifier == "hydrationReminder" }
                completion(hydrationReminders)
            }
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}