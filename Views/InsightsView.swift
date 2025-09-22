import SwiftUI

struct InsightsView: View {
    let insights: [Insight]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(insights.indices, id: \.self) { index in
                        InsightDetailView(insight: insights[index])
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                    
                    if insights.isEmpty {
                        EmptyStateView(
                            icon: "lightbulb.slash",
                            title: "No Insights Yet",
                            message: "Keep tracking your intake to receive personalized insights and recommendations."
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Your Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: insights)
        }
    }
}

struct InsightDetailView: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.system(size: 28))
                    .foregroundColor(insight.type.color)
                    .frame(width: 40, height: 40)
                    .background(insight.type.color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(insight.type.name)
                        .font(.caption)
                        .foregroundColor(insight.type.color)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            if let action = insight.action {
                Button(action: action) {
                    HStack {
                        Text("Take Action")
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right.circle")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(insight.type.color)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

extension Insight.InsightType {
    var name: String {
        switch self {
        case .success: return "Success"
        case .warning: return "Warning"
        case .info: return "Tip"
        }
    }
}

extension Insight {
    var action: (() -> Void)? {
        switch type {
        case .warning where title.contains("Water"):
            return {
                // Navigate to settings to set reminder
                print("Navigate to hydration reminder settings")
            }
        case .info where title.contains("Peak"):
            return {
                // Suggest setting reminder at peak time
                print("Suggest reminder at peak time")
            }
        default:
            return nil
        }
    }
}

#Preview {
    InsightsView(insights: [
        Insight(
            title: "Great Progress!",
            description: "Your water intake has been consistently increasing over the past week. Keep up the excellent work in maintaining your hydration goals!",
            type: .success,
            icon: "checkmark.circle.fill"
        ),
        Insight(
            title: "High Caffeine Intake",
            description: "Your average caffeine consumption exceeds 400mg per day. Consider switching to decaf options after 2 PM to improve sleep quality.",
            type: .warning,
            icon: "exclamationmark.triangle.fill"
        )
    ])
}