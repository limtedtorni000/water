import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingInsights = false
    @State private var animateCharts = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
        
        var icon: String {
            switch self {
            case .week: return "calendar.badge.clock"
            case .month: return "calendar.badge.month"
            case .year: return "calendar.badge.year"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(UIColor.systemGroupedBackground),
                        Color(UIColor.secondarySystemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header with time selector
                        headerSection
                        
                        // Summary cards with improved design
                        summarySection
                        
                        // Charts with enhanced visuals
                        chartsSection
                        
                        // Pattern insights
                        patternsSection
                        
                        // Weekly highlights
                        weeklyHighlightsSection
                        
                        // Insights preview
                        insightsSection
                        
                        // Achievements showcase
                        achievementsSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInsights = true }) {
                        Image(systemName: "lightbulb.circle.fill")
                            .font(.title3)
                            .foregroundColor(.waterBlue)
                    }
                }
            }
            .sheet(isPresented: $showingInsights) {
                InsightsView(insights: viewModel.insights)
            }
            .onAppear {
                viewModel.loadData(for: selectedTimeRange)
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    animateCharts = true
                }
            }
            .onChange(of: selectedTimeRange) { _, _ in
                viewModel.loadData(for: selectedTimeRange)
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateCharts = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateCharts = true
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Hydration Journey")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Time range selector
                HStack(spacing: 8) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTimeRange = range
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: range.icon)
                                    .font(.system(size: 18, weight: .medium))
                                
                                Text(range.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTimeRange == range ? Color.waterBlue.opacity(0.15) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedTimeRange == range ? Color.waterBlue : Color.clear, lineWidth: 2)
                                    )
                            )
                            .scaleEffect(selectedTimeRange == range ? 1.05 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: 280)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(selectedTimeRange.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                EnhancedSummaryCard(
                    title: "Water",
                    value: String(format: "%.0f", viewModel.totalWater),
                    unit: viewModel.waterUnit,
                    color: .waterBlue,
                    trend: viewModel.waterTrend,
                    icon: "drop.fill"
                )
                
                EnhancedSummaryCard(
                    title: "Caffeine",
                    value: String(format: "%.0f", viewModel.totalCaffeine),
                    unit: viewModel.caffeineUnit,
                    color: .caffeineBrown,
                    trend: viewModel.caffeineTrend,
                    icon: "mug.fill"
                )
                
                EnhancedSummaryCard(
                    title: "Active Days",
                    value: "\(viewModel.activeDays)",
                    unit: "days",
                    color: .purple,
                    trend: viewModel.consistencyTrend,
                    icon: "calendar.badge.checkmark"
                )
            }
        }
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(spacing: 24) {
            Text("Consumption Patterns")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                // Water chart with animation
                EnhancedChartCard(
                    title: "Water Intake",
                    subtitle: "Daily consumption trends",
                    color: .waterBlue,
                    icon: "drop.fill"
                ) {
                    Chart {
                        ForEach(viewModel.dailyData, id: \.date) { day in
                            LineMark(
                                x: .value("Date", day.date),
                                y: .value("Water", day.waterAmount)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.waterBlue, Color.waterBlue.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            .symbolSize(60)
                            
                            AreaMark(
                                x: .value("Date", day.date),
                                y: .value("Water", day.waterAmount)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [
                                        Color.waterBlue.opacity(0.4),
                                        Color.waterBlue.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(preset: .automatic, position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(preset: .automatic, position: .leading)
                    }
                    .chartPlotStyle { plotArea in
                        plotArea.background(Color.clear)
                    }
                    .scaleEffect(y: animateCharts ? 1.0 : 0.8)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCharts)
                }
                
                // Caffeine chart with animation
                EnhancedChartCard(
                    title: "Caffeine Intake",
                    subtitle: "Daily consumption patterns",
                    color: .caffeineBrown,
                    icon: "mug.fill"
                ) {
                    Chart {
                        ForEach(viewModel.dailyData, id: \.date) { day in
                            BarMark(
                                x: .value("Date", day.date),
                                y: .value("Caffeine", day.caffeineAmount),
                                width: .fixed(20)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.caffeineBrown, Color.caffeineBrown.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(6)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(preset: .automatic, position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(preset: .automatic, position: .leading)
                    }
                    .chartPlotStyle { plotArea in
                        plotArea.background(Color.clear)
                    }
                    .scaleEffect(y: animateCharts ? 1.0 : 0.8)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCharts)
                }
            }
        }
    }
    
    // MARK: - Patterns Section
    private var patternsSection: some View {
        VStack(spacing: 20) {
            Text("Habit Insights")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                EnhancedPatternCard(
                    icon: "clock.fill",
                    title: "Peak Time",
                    value: viewModel.peakIntakeTime,
                    subtitle: "When you drink most",
                    color: .blue,
                    unit: nil
                )
                
                EnhancedPatternCard(
                    icon: "calendar.badge.clock",
                    title: "Active Day",
                    value: viewModel.mostActiveDay,
                    subtitle: "Your most consistent day",
                    color: .purple,
                    unit: nil
                )
                
                EnhancedPatternCard(
                    icon: "target",
                    title: "Goal Rate",
                    value: viewModel.goalAchievementRate,
                    subtitle: "Achievement success",
                    color: .green,
                    unit: nil
                )
                
                EnhancedPatternCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: String(format: "%.0f", viewModel.weeklyAverageWater),
                    subtitle: "Daily average water",
                    color: .orange,
                    unit: viewModel.waterUnit
                )
            }
        }
    }
    
    // MARK: - Weekly Highlights Section
    private var weeklyHighlightsSection: some View {
        VStack(spacing: 20) {
            Text("Weekly Highlights")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ModernCard(
                padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            ) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Best Day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text(getBestDay())
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.waterBlue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Streak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text("\(getCurrentStreak()) days")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This Week's Goal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: getWeeklyProgress(), total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .waterBlue))
                                .scaleEffect(y: 2)
                            
                            Text("\(Int(getWeeklyProgress() * 100))% complete")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("AI Insights")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { 
                    showingInsights = true
                    AnalyticsService.shared.trackEvent(.insights_viewed)
                }) {
                    HStack(spacing: 6) {
                        Text("View All")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.waterBlue)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.waterBlue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.waterBlue.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            
            if viewModel.insights.isEmpty {
                ModernCard(
                    padding: EdgeInsets(top: 32, leading: 20, bottom: 32, trailing: 20)
                ) {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("No insights yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Keep tracking to see personalized insights")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Top insights grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.insights.prefix(2)) { insight in
                        EnhancedInsightCard(insight: insight)
                    }
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.achievements.filter { $0.unlocked }.count)/\(viewModel.achievements.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if viewModel.achievements.isEmpty {
                ModernCard(
                    padding: EdgeInsets(top: 32, leading: 20, bottom: 32, trailing: 20)
                ) {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("No achievements yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Start tracking to earn achievements")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                // Achievement grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.achievements.prefix(6)) { achievement in
                        EnhancedAchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getBestDay() -> String {
        guard !viewModel.dailyData.isEmpty else { return "No data" }
        
        let bestDay = viewModel.dailyData
            .max { $0.waterAmount + $0.caffeineAmount < $1.waterAmount + $1.caffeineAmount }
        
        if let bestDay = bestDay {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: bestDay.date)
        }
        
        return "No data"
    }
    
    private func getCurrentStreak() -> Int {
        // Simple streak calculation based on consecutive days with data
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        while true {
            let dayData = viewModel.dailyData.first { calendar.isDate($0.date, inSameDayAs: checkDate) }
            if dayData != nil && (dayData!.waterAmount > 0 || dayData!.caffeineAmount > 0) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func getWeeklyProgress() -> Double {
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
        
        let weekEntries = viewModel.dailyData.filter { $0.date >= weekStart && $0.date < weekEnd }
        let totalWater = weekEntries.reduce(0) { $0 + $1.waterAmount }
        
        // Use default daily water goal of 2000ml
        let weeklyGoal = 2000.0 * 7
        
        return min(totalWater / weeklyGoal, 1.0)
    }
}

// MARK: - Enhanced UI Components
struct EnhancedSummaryCard: View {
    let title: String
    let value: String
    let unit: String?
    let color: Color
    let trend: TrendDirection?
    let icon: String
    
    var body: some View {
        ModernCard(
            padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            VStack(spacing: 12) {
                // Icon and title
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption2)
                                .foregroundColor(trend.color)
                            
                            Text(trend.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(trend.color.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                // Value
                VStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                    
                    if let unit = unit {
                        Text(unit)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
    }
}

struct TrendDirection: Hashable {
    enum Direction {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .gray
            }
        }
        
        var rawValue: String {
            switch self {
            case .up: return "Up"
            case .down: return "Down"
            case .stable: return "Stable"
            }
        }
    }
    
    let direction: Direction
    let percentage: Double?
    
    init(direction: Direction, percentage: Double? = nil) {
        self.direction = direction
        self.percentage = percentage
    }
    
    var icon: String { direction.icon }
    var color: Color { direction.color }
    var rawValue: String { 
        if let percentage = percentage {
            return "\(direction.rawValue) \(Int(percentage))%"
        }
        return direction.rawValue
    }
}

struct EnhancedChartCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let color: Color
    let icon: String
    let content: Content
    
    init(title: String, subtitle: String? = nil, color: Color, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        ModernCard(
            padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Content
                content
            }
        }
    }
}

struct EnhancedPatternCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let unit: String?
    
    var body: some View {
        ModernCard(
            padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Value
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if let unit = unit {
                        Text(unit)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }
                
                // Title and subtitle
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

struct EnhancedInsightCard: View {
    let insight: Insight
    
    var body: some View {
        ModernCard(
            padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        ) {
            VStack(spacing: 12) {
                // Icon and type
                HStack {
                    ZStack {
                        Circle()
                            .fill(insight.type.color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: insight.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(insight.type.color)
                    }
                    
                    Spacer()
                    
                    Text(insight.type.rawValue.capitalized)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(insight.type.color)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(insight.type.color.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(insight.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(insight.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

struct InsightCard: View {
    let insight: Insight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundColor(insight.type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(insight.type.color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EnhancedAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        ModernCard(
            padding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        ) {
            VStack(spacing: 8) {
                // Icon with animation for unlocked achievements
                ZStack {
                    Circle()
                        .fill(achievement.unlocked ? achievement.color.opacity(0.15) : Color.secondary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 24, weight: achievement.unlocked ? .semibold : .regular))
                        .foregroundColor(achievement.unlocked ? achievement.color : .gray)
                        .scaleEffect(achievement.unlocked ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: achievement.unlocked)
                }
                
                // Title
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Progress
                if achievement.unlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text("Unlocked")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.green)
                            .textCase(.uppercase)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
                } else {
                    VStack(spacing: 4) {
                        // Progress bar
                        ProgressView(value: Double(achievement.progress), total: Double(achievement.target))
                            .progressViewStyle(LinearProgressViewStyle(tint: achievement.color))
                            .scaleEffect(x: 1, y: 1.5)
                        
                        // Progress text
                        Text("\(achievement.progress)/\(achievement.target)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.unlocked ? achievement.color : .gray)
            
            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            if achievement.unlocked {
                Text("✓")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else {
                Text("\(achievement.progress)/\(achievement.target)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(achievement.unlocked ? achievement.color.opacity(0.1) : Color.secondaryBackground)
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
        .onAppear {
            AnalyticsService.shared.trackScreen("User Analytics")
        }
}