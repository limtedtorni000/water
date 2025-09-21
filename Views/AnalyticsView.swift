import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingInsights = false
    
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
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with summary
                    summarySection
                    
                    // Charts
                    chartsSection
                    
                    // Patterns
                    patternsSection
                    
                    // Insights
                    insightsSection
                    
                    // Achievements
                    achievementsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Your Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Button(action: { showingInsights = true }) {
                            Label("View Insights", systemImage: "lightbulb")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingInsights) {
                InsightsView(insights: viewModel.insights)
            }
            .onAppear {
                viewModel.loadData(for: selectedTimeRange)
            }
            .onChange(of: selectedTimeRange) { _, _ in
                viewModel.loadData(for: selectedTimeRange)
            }
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SummaryCard(
                    title: "Total Water",
                    value: "\(String(format: "%.0f", viewModel.totalWater)) \(viewModel.waterUnit)",
                    color: .waterBlue,
                    trend: viewModel.waterTrend
                )
                
                SummaryCard(
                    title: "Total Caffeine",
                    value: "\(String(format: "%.0f", viewModel.totalCaffeine)) \(viewModel.caffeineUnit)",
                    color: .caffeineBrown,
                    trend: viewModel.caffeineTrend
                )
                
                SummaryCard(
                    title: "Active Days",
                    value: "\(viewModel.activeDays)",
                    color: .green,
                    trend: viewModel.consistencyTrend
                )
            }
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            Text("Consumption Trends")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Water chart
                ChartCard(title: "Water Intake", color: .waterBlue) {
                    Chart {
                        ForEach(viewModel.dailyData, id: \.date) { day in
                            LineMark(
                                x: .value("Date", day.date),
                                y: .value("Water", day.waterAmount)
                            )
                            .foregroundStyle(Color.waterBlue)
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            
                            AreaMark(
                                x: .value("Date", day.date),
                                y: .value("Water", day.waterAmount)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.waterBlue.opacity(0.3), Color.waterBlue.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 180)
                }
                
                // Caffeine chart
                ChartCard(title: "Caffeine Intake", color: .caffeineBrown) {
                    Chart {
                        ForEach(viewModel.dailyData, id: \.date) { day in
                            BarMark(
                                x: .value("Date", day.date),
                                y: .value("Caffeine", day.caffeineAmount)
                            )
                            .foregroundStyle(Color.caffeineBrown)
                        }
                    }
                    .frame(height: 180)
                }
            }
        }
    }
    
    private var patternsSection: some View {
        VStack(spacing: 16) {
            Text("Your Patterns")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                PatternRow(
                    icon: "clock.fill",
                    title: "Peak Intake Time",
                    value: viewModel.peakIntakeTime,
                    color: .blue
                )
                
                PatternRow(
                    icon: "calendar.badge.clock",
                    title: "Most Active Day",
                    value: viewModel.mostActiveDay,
                    color: .purple
                )
                
                PatternRow(
                    icon: "target",
                    title: "Goal Achievement",
                    value: viewModel.goalAchievementRate,
                    color: .green
                )
                
                PatternRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Weekly Average",
                    value: "\(String(format: "%.0f", viewModel.weeklyAverageWater)) \(viewModel.waterUnit)",
                    color: .orange
                )
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Insights")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingInsights = true }) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.waterBlue)
                }
            }
            
            if let topInsight = viewModel.insights.first {
                InsightCard(insight: topInsight)
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.achievements.prefix(6)) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption2)
                        .foregroundColor(trend.color)
                    
                    Text(trend == .up ? "vs last period" : trend == .down ? "vs last period" : "same as last period")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    let color: Color
    let content: Content
    
    init(title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            content
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(16)
    }
}

struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
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