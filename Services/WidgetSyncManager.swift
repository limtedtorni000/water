import Foundation
import CoreData
import UIKit

// MARK: - App-to-Widget Data Sync Manager
class WidgetSyncManager {
    static let shared = WidgetSyncManager()
    private let appGroup = "group.hydratrack"
    
    private init() {}
    
    // Sync hydration data to widget
    func syncHydrationData(context: NSManagedObjectContext) {
        let dataManager = WidgetDataManager.shared
        
        // Get today's entries
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let entries = try context.fetch(fetchRequest)
            
            // Calculate current intake
            var currentWater: Double = 0
            var currentCaffeine: Double = 0
            var intakeEntries: [WidgetIntakeEntry] = []
            
            for entry in entries {
                let amount = entry.amount
                
                if entry.type == "water" || entry.type == "both" {
                    currentWater += amount
                }
                if entry.type == "caffeine" || entry.type == "both" {
                    currentCaffeine += amount
                }
                
                intakeEntries.append(WidgetIntakeEntry(
                    amount: amount,
                    type: entry.type ?? "",
                    date: entry.date ?? Date()
                ))
            }
            
            // Get user preferences
            let preferences = dataManager.getUserPreferences()
            
            // Create hydration data
            let hydrationData = HydrationData(
                currentWater: currentWater,
                waterGoal: preferences.waterGoal,
                currentCaffeine: currentCaffeine,
                caffeineGoal: preferences.caffeineGoal,
                waterUnit: preferences.waterUnit,
                caffeineUnit: preferences.caffeineUnit,
                lastUpdated: Date(),
                entries: intakeEntries
            )
            
            // Save to shared storage
            dataManager.saveHydrationData(hydrationData)
            
            // Update weekly analytics
            updateWeeklyAnalytics(context: context)
            
        } catch {
            print("Error syncing hydration data: \(error)")
        }
    }
    
    // Update weekly analytics
    private func updateWeeklyAnalytics(context: NSManagedObjectContext) {
        let dataManager = WidgetDataManager.shared
        
        // Get last 7 days of data
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        let fetchRequest: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@", weekAgo as NSDate)
        
        do {
            let entries = try context.fetch(fetchRequest)
            
            // Group by day
            var dailyData: [Date: (water: Double, caffeine: Double)] = [:]
            
            for entry in entries {
                guard let entryDate = entry.date else { continue }
                let day = calendar.startOfDay(for: entryDate)
                
                if dailyData[day] == nil {
                    dailyData[day] = (0, 0)
                }
                
                if entry.type == "water" || entry.type == "both" {
                    dailyData[day]?.water += entry.amount
                }
                if entry.type == "caffeine" || entry.type == "both" {
                    dailyData[day]?.caffeine += entry.amount
                }
            }
            
            // Create week data array
            var weekData: [DayData] = []
            var totalWater: Double = 0
            var totalCaffeine: Double = 0
            var daysWithGoal = 0
            
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: weekAgo)!
                let dayIntake = dailyData[date] ?? (0, 0)
                
                let preferences = dataManager.getUserPreferences()
                let goalReached = dayIntake.water >= preferences.waterGoal
                
                weekData.append(DayData(
                    date: date,
                    waterIntake: dayIntake.water,
                    caffeineIntake: dayIntake.caffeine,
                    goalReached: goalReached
                ))
                
                totalWater += dayIntake.water
                totalCaffeine += dayIntake.caffeine
                if goalReached { daysWithGoal += 1 }
            }
            
            // Calculate trends
            let averageWater = totalWater / 7
            let averageCaffeine = totalCaffeine / 7
            
            // Simple trend calculation (compare first half vs second half of week)
            let firstHalf = weekData.prefix(3).reduce(0) { $0 + $1.waterIntake } / 3
            let secondHalf = weekData.suffix(3).reduce(0) { $0 + $1.waterIntake } / 3
            
            let trend: WeeklyAnalytics.TrendDirection
            if secondHalf > firstHalf * 1.1 {
                trend = .up
            } else if secondHalf < firstHalf * 0.9 {
                trend = .down
            } else {
                trend = .stable
            }
            
            // Create analytics data
            let analytics = WeeklyAnalytics(
                weekData: weekData,
                averageWater: averageWater,
                averageCaffeine: averageCaffeine,
                trend: trend
            )
            
            // Save to shared storage
            dataManager.saveWeeklyAnalytics(analytics)
            
        } catch {
            print("Error updating weekly analytics: \(error)")
        }
    }
    
    // Handle URL scheme for widget actions
    func handleWidgetAction(url: URL, context: NSManagedObjectContext) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "add":
            handleAddAction(components, context: context)
        case "home":
            // Navigate to home view
            NotificationCenter.default.post(name: .navigateToHome, object: nil)
        case "analytics":
            // Navigate to analytics view
            NotificationCenter.default.post(name: .navigateToAnalytics, object: nil)
        default:
            break
        }
    }
    
    private func handleAddAction(_ components: URLComponents, context: NSManagedObjectContext) {
        guard let queryItems = components.queryItems else { return }
        
        let type = queryItems.first(where: { $0.name == "type" })?.value
        let amountString = queryItems.first(where: { $0.name == "amount" })?.value
        
        guard let type = type,
              let amountString = amountString,
              let amount = Double(amountString) else { return }
        
        // Add entry to Core Data
        let newEntry = IntakeEntry(context: context)
        newEntry.amount = amount
        newEntry.type = type
        newEntry.date = Date()
        
        do {
            try context.save()
            
            // Sync data to widget
            syncHydrationData(context: context)
            
            // Show haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        } catch {
            print("Error adding intake entry: \(error)")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToHome = Notification.Name("navigateToHome")
    static let navigateToAnalytics = Notification.Name("navigateToAnalytics")
    static let widgetDataUpdated = Notification.Name("widgetDataUpdated")
}

