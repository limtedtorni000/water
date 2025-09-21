import Foundation
import Combine
import CoreData
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var weeklyData: [DailyIntake] = []
    @Published var monthlyData: [DailyIntake] = []
    @Published var selectedTimeRange: TimeRange = .week
    
    private let storageService = StorageService.shared
    
    enum TimeRange {
        case week
        case month
    }
    
    struct DailyIntake: Identifiable {
        let id = UUID()
        let date: Date
        let waterAmount: Double
        let caffeineAmount: Double
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeRange {
        case .week:
            let startDate = calendar.date(byAdding: .day, value: -6, to: today)!
            weeklyData = getDailyData(from: startDate, to: today)
        case .month:
            let startDate = calendar.date(byAdding: .day, value: -29, to: today)!
            monthlyData = getDailyData(from: startDate, to: today)
        }
    }
    
    func changeTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        loadData()
    }
    
    private func getDailyData(from startDate: Date, to endDate: Date) -> [DailyIntake] {
        let entries = storageService.fetchEntries(forDateRange: startDate, end: endDate)
        let calendar = Calendar.current
        
        var dailyTotals: [Date: (water: Double, caffeine: Double)] = [:]
        
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date ?? Date())
            let intakeType = StorageService.shared.getIntakeType(for: entry)
            if var totals = dailyTotals[day] {
                if intakeType == .water {
                    totals.water += entry.amount
                } else {
                    totals.caffeine += entry.amount
                }
                dailyTotals[day] = totals
            } else {
                if intakeType == .water {
                    dailyTotals[day] = (water: entry.amount, caffeine: 0)
                } else {
                    dailyTotals[day] = (water: 0, caffeine: entry.amount)
                }
            }
        }
        
        var result: [DailyIntake] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let totals = dailyTotals[calendar.startOfDay(for: currentDate)] ?? (water: 0, caffeine: 0)
            result.append(DailyIntake(
                date: currentDate,
                waterAmount: totals.water,
                caffeineAmount: totals.caffeine
            ))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    func getAverageWater() -> Double {
        let data = selectedTimeRange == .week ? weeklyData : monthlyData
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.waterAmount }
        return total / Double(data.count)
    }
    
    func getAverageCaffeine() -> Double {
        let data = selectedTimeRange == .week ? weeklyData : monthlyData
        guard !data.isEmpty else { return 0 }
        let total = data.reduce(0) { $0 + $1.caffeineAmount }
        return total / Double(data.count)
    }
}