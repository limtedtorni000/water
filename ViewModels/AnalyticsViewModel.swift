import Foundation
import SwiftUI
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var dailyData: [DailyIntake] = []
    @Published var totalWater: Double = 0
    @Published var totalCaffeine: Double = 0
    @Published var activeDays: Int = 0
    @Published var waterUnit = "ml"
    @Published var caffeineUnit = "mg"
    @Published var waterTrend: TrendDirection?
    @Published var caffeineTrend: TrendDirection?
    @Published var consistencyTrend: TrendDirection?
    @Published var peakIntakeTime = "N/A"
    @Published var mostActiveDay = "N/A"
    @Published var goalAchievementRate = "N/A"
    @Published var weeklyAverageWater: Double = 0
    @Published var insights: [Insight] = []
    @Published var achievements: [Achievement] = []
    
    private let storageService = StorageService.shared
    private let analyticsService = AnalyticsService.shared
    private let intakeViewModel: IntakeViewModel
    
    init(intakeViewModel: IntakeViewModel) {
        self.intakeViewModel = intakeViewModel
    }
    
    struct DailyIntake: Identifiable {
        let id = UUID()
        let date: Date
        let waterAmount: Double
        let caffeineAmount: Double
        let dayOfWeek: String
    }
    
    func loadData(for timeRange: AnalyticsView.TimeRange) {
        // Load user preferences
        waterUnit = intakeViewModel.waterUnit
        caffeineUnit = intakeViewModel.caffeineUnit
        
        // Get intake entries for the time range
        let entries = storageService.getIntakeEntries(for: timeRange.days)
        
        // Process daily data
        processDailyData(from: entries)
        
        // Calculate totals
        calculateTotals()
        
        // Analyze patterns
        analyzePatterns()
        
        // Generate insights
        generateInsights()
        
        // Update achievements
        updateAchievements()
        
        // Track analytics
        analyticsService.trackEvent(.analytics_viewed, parameters: [
            "time_range": timeRange.rawValue,
            "days_analyzed": timeRange.days
        ])
    }
    
    private func processDailyData(from entries: [IntakeEntry]) {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date ?? Date())
        }
        
        dailyData = groupedByDay.map { date, entries in
            let waterAmount = entries
                .filter { $0.type == "water" }
                .reduce(0) { $0 + $1.amount }
            
            let caffeineAmount = entries
                .filter { $0.type == "caffeine" }
                .reduce(0) { $0 + $1.amount }
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            let dayOfWeek = dayFormatter.string(from: date)
            
            return DailyIntake(
                date: date,
                waterAmount: waterAmount,
                caffeineAmount: caffeineAmount,
                dayOfWeek: dayOfWeek
            )
        }.sorted { $0.date < $1.date }
    }
    
    private func splitDataForTrendAnalysis() -> (firstHalf: [DailyIntake], secondHalf: [DailyIntake]) {
        guard dailyData.count >= 2 else {
            return ([], [])
        }
        
        let midpoint = dailyData.count / 2
        if dailyData.count % 2 == 0 {
            // Even number of days - clean split
            let firstHalf = Array(dailyData.prefix(midpoint))
            let secondHalf = Array(dailyData.suffix(midpoint))
            return (firstHalf, secondHalf)
        } else {
            // Odd number of days - include middle day in both halves for better trend detection
            let firstHalf = Array(dailyData.prefix(midpoint + 1))
            let secondHalf = Array(dailyData.suffix(midpoint + 1))
            return (firstHalf, secondHalf)
        }
    }
    
    private func calculateTotals() {
        totalWater = dailyData.reduce(0) { $0 + $1.waterAmount }
        totalCaffeine = dailyData.reduce(0) { $0 + $1.caffeineAmount }
        activeDays = dailyData.filter { $0.waterAmount > 0 || $0.caffeineAmount > 0 }.count
        weeklyAverageWater = dailyData.count > 0 ? totalWater / Double(dailyData.count) : 0
        
        // Calculate trends (comparing first half with second half)
        let (firstHalf, secondHalf) = splitDataForTrendAnalysis()
        if !firstHalf.isEmpty && !secondHalf.isEmpty {
            
            let firstHalfWater = firstHalf.reduce(0) { $0 + $1.waterAmount }
            let secondHalfWater = secondHalf.reduce(0) { $0 + $1.waterAmount }
            
            // Water trend with division by zero protection
            if firstHalfWater > 0 {
                if secondHalfWater > firstHalfWater * 1.1 {
                    waterTrend = TrendDirection(direction: .up, percentage: ((secondHalfWater - firstHalfWater) / firstHalfWater) * 100)
                } else if secondHalfWater < firstHalfWater * 0.9 {
                    waterTrend = TrendDirection(direction: .down, percentage: ((firstHalfWater - secondHalfWater) / firstHalfWater) * 100)
                } else {
                    waterTrend = TrendDirection(direction: .stable)
                }
            } else {
                // First half had no water intake
                waterTrend = secondHalfWater > 0 ? TrendDirection(direction: .up) : TrendDirection(direction: .stable)
            }
            
            let firstHalfCaffeine = firstHalf.reduce(0) { $0 + $1.caffeineAmount }
            let secondHalfCaffeine = secondHalf.reduce(0) { $0 + $1.caffeineAmount }
            
            // Caffeine trend with division by zero protection
            if firstHalfCaffeine > 0 {
                if secondHalfCaffeine > firstHalfCaffeine * 1.1 {
                    caffeineTrend = TrendDirection(direction: .up, percentage: ((secondHalfCaffeine - firstHalfCaffeine) / firstHalfCaffeine) * 100)
                } else if secondHalfCaffeine < firstHalfCaffeine * 0.9 {
                    caffeineTrend = TrendDirection(direction: .down, percentage: ((firstHalfCaffeine - secondHalfCaffeine) / firstHalfCaffeine) * 100)
                } else {
                    caffeineTrend = TrendDirection(direction: .stable)
                }
            } else {
                // First half had no caffeine intake
                caffeineTrend = secondHalfCaffeine > 0 ? TrendDirection(direction: .up) : TrendDirection(direction: .stable)
            }
            
            // Consistency trend based on active days
            let firstHalfActive = firstHalf.filter { $0.waterAmount > 0 }.count
            let secondHalfActive = secondHalf.filter { $0.waterAmount > 0 }.count
            
            if secondHalfActive > firstHalfActive {
                consistencyTrend = TrendDirection(direction: .up)
            } else if secondHalfActive < firstHalfActive {
                consistencyTrend = TrendDirection(direction: .down)
            } else {
                consistencyTrend = TrendDirection(direction: .stable)
            }
        }
    }
    
    private func analyzePatterns() {
        // Peak intake time
        var hourlyWater = Array(repeating: 0.0, count: 24)
        let entries = storageService.getIntakeEntries(for: 30) // Use 30 days for pattern analysis
        
        for entry in entries {
            guard let date = entry.date else { continue }
            let hour = Calendar.current.component(.hour, from: date)
            if entry.type == "water" {
                hourlyWater[hour] += entry.amount
            }
        }
        
        // Find peak time with minimum threshold
        let maxWaterAmount = hourlyWater.max() ?? 0
        if maxWaterAmount > 0 { // Only show peak if there's actual data
            if let maxIndex = hourlyWater.indices.max(by: { hourlyWater[$0] < hourlyWater[$1] }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "h a"
                let date = Calendar.current.date(bySettingHour: maxIndex, minute: 0, second: 0, of: Date())!
                peakIntakeTime = formatter.string(from: date)
            }
        } else {
            peakIntakeTime = "N/A"
        }
        
        // Most active day
        let dayTotals = Dictionary(grouping: dailyData, by: \.dayOfWeek)
            .mapValues { $0.reduce(0) { $0 + $1.waterAmount } }
        
        if let mostActive = dayTotals.max(by: { $0.value < $1.value }) {
            mostActiveDay = mostActive.key
        }
        
        // Goal achievement rate
        let waterGoal = intakeViewModel.waterGoal
        
        let daysWithGoal = dailyData.filter { $0.waterAmount >= waterGoal }.count
        
        // Use total days in period as denominator for accurate achievement rate
        if dailyData.count > 0 {
            let rate = Double(daysWithGoal) / Double(dailyData.count) * 100
            goalAchievementRate = String(format: "%.0f%%", rate)
        } else {
            goalAchievementRate = "0%"
        }
    }
    
    private func generateInsights() {
        insights.removeAll()
        
        guard !dailyData.isEmpty else {
            // No data insight
            insights.append(Insight(
                title: "Start Tracking",
                description: "Begin tracking your water intake to see personalized insights and recommendations.",
                type: .info,
                icon: "drop.fill"
            ))
            return
        }
        
        // Water intake insights
        if weeklyAverageWater < 1500 && weeklyAverageWater > 0 {
            insights.append(Insight(
                title: "Low Water Intake",
                description: "Your average water intake is below recommended levels. Try to drink more water throughout the day.",
                type: .warning,
                icon: "exclamationmark.triangle.fill"
            ))
        } else if weeklyAverageWater >= 2000 {
            insights.append(Insight(
                title: "Great Hydration!",
                description: "You're meeting recommended water intake levels. Keep up the excellent work!",
                type: .success,
                icon: "checkmark.circle.fill"
            ))
        }
        
        // Trend insights
        if let trend = waterTrend {
            switch trend.direction {
            case .up:
                if let percentage = trend.percentage, percentage > 20 {
                    insights.append(Insight(
                        title: "Significant Improvement!",
                        description: "Your water intake has increased by \(String(format: "%.0f", percentage))%. Excellent progress!",
                        type: .success,
                        icon: "chart.line.uptrend.xyaxis"
                    ))
                } else {
                    insights.append(Insight(
                        title: "Steady Progress",
                        description: "Your water intake is trending upward. Keep building this positive habit!",
                        type: .success,
                        icon: "arrow.up.circle.fill"
                    ))
                }
            case .down:
                insights.append(Insight(
                    title: "Decreasing Intake",
                    description: "Your water intake has been decreasing. Try to set reminders to stay hydrated.",
                    type: .warning,
                    icon: "arrow.down.circle.fill"
                ))
            case .stable:
                insights.append(Insight(
                    title: "Consistent Intake",
                    description: "You're maintaining a steady water intake routine. Consistency is key!",
                    type: .info,
                    icon: "equal.circle.fill"
                ))
            }
        }
        
        // Caffeine insights
        let avgCaffeine = dailyData.count > 0 ? totalCaffeine / Double(dailyData.count) : 0
        if avgCaffeine > 400 {
            insights.append(Insight(
                title: "High Caffeine Intake",
                description: "Your average caffeine intake exceeds recommended daily limits. Consider reducing consumption.",
                type: .warning,
                icon: "exclamationmark.triangle.fill"
            ))
        } else if avgCaffeine > 0 && avgCaffeine <= 200 {
            insights.append(Insight(
                title: "Moderate Caffeine",
                description: "Your caffeine intake is within healthy limits. Good job maintaining balance!",
                type: .success,
                icon: "checkmark.circle.fill"
            ))
        }
        
        // Consistency insights
        if let trend = consistencyTrend, trend.direction == .up {
            insights.append(Insight(
                title: "Building Consistency",
                description: "You're tracking your intake more consistently. This is great for forming healthy habits!",
                type: .success,
                icon: "checkmark.circle.fill"
            ))
        }
        
        // Goal achievement insights
        if let achievementRate = Double(goalAchievementRate.replacingOccurrences(of: "%", with: "")) {
            if achievementRate >= 80 {
                insights.append(Insight(
                    title: "Goal Crusher!",
                    description: "You're meeting your hydration goals \(Int(achievementRate))% of the time. Outstanding!",
                    type: .success,
                    icon: "target"
                ))
            } else if achievementRate >= 50 {
                insights.append(Insight(
                    title: "Making Progress",
                    description: "You're meeting your goals \(Int(achievementRate))% of the time. Keep pushing!",
                    type: .info,
                    icon: "chart.line.uptrend.xyaxis"
                ))
            } else if achievementRate > 0 {
                insights.append(Insight(
                    title: "Room for Improvement",
                    description: "You're meeting goals \(Int(achievementRate))% of the time. Try setting more reminders.",
                    type: .warning,
                    icon: "exclamationmark.triangle.fill"
                ))
            }
        }
        
        // Time-based insights
        if !peakIntakeTime.isEmpty && peakIntakeTime != "N/A" {
            insights.append(Insight(
                title: "Peak Hydration Time",
                description: "You tend to drink the most water at \(peakIntakeTime). Consider setting a reminder before this time.",
                type: .info,
                icon: "clock.fill"
            ))
        }
        
        // Most active day insight
        if mostActiveDay != "N/A" {
            insights.append(Insight(
                title: "\(mostActiveDay) Warrior",
                description: "\(mostActiveDay) is your most active hydration day. Keep that momentum going!",
                type: .info,
                icon: "calendar.badge.checkmark"
            ))
        }
    }
    
    private func updateAchievements() {
        achievements = [
            Achievement(
                title: "First Sip",
                description: "Track your first intake",
                icon: "drop.fill",
                color: .waterBlue,
                target: 1,
                progress: min(totalWater > 0 ? 1 : 0, 1),
                unlocked: totalWater > 0
            ),
            Achievement(
                title: "Hydration Hero",
                description: "Drink 2L of water in a day",
                icon: "star.fill",
                color: .yellow,
                target: 2000,
                progress: Int(totalWater),
                unlocked: dailyData.contains { $0.waterAmount >= 2000 }
            ),
            Achievement(
                title: "Week Warrior",
                description: "Track for 7 consecutive days",
                icon: "calendar.badge.checkmark",
                color: .green,
                target: 7,
                progress: min(activeDays, 7),
                unlocked: activeDays >= 7
            ),
            Achievement(
                title: "Goal Getter",
                description: "Meet your daily goal 5 times",
                icon: "target",
                color: .purple,
                target: 5,
                progress: dailyData.filter { $0.waterAmount >= intakeViewModel.waterGoal }.count,
                unlocked: dailyData.filter { $0.waterAmount >= intakeViewModel.waterGoal }.count >= 5
            ),
            Achievement(
                title: "Morning Person",
                description: "Track intake before 9 AM for 3 days",
                icon: "sun.fill",
                color: .orange,
                target: 3,
                progress: 0, // Would need more detailed tracking
                unlocked: false
            ),
            Achievement(
                title: "Data Exporter",
                description: "Export your data",
                icon: "square.and.arrow.up",
                color: .blue,
                target: 1,
                progress: 0, // Would need to track exports
                unlocked: false
            )
        ]
    }
}

struct Insight: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let type: InsightType
    let icon: String
    
    enum InsightType: Equatable {
        case success, warning, info
        
        var color: Color {
            switch self {
            case .success: return .successGreen
            case .warning: return .warningRed
            case .info: return .infoBlue
            }
        }
        
        var rawValue: String {
            switch self {
            case .success: return "success"
            case .warning: return "warning"
            case .info: return "info"
            }
        }
    }
}

struct Achievement: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let target: Int
    let progress: Int
    let unlocked: Bool
}