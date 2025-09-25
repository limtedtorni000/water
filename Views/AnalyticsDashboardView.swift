import SwiftUI

struct AnalyticsDashboardView: View {
    @State private var events: [[String: Any]] = []
    @State private var userProperties: [String: Any] = [:]
    @State private var showRawData = false
    @State private var selectedEventFilter = "All"
    
    private let analyticsService = AnalyticsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Info Section
                    userInfoSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Event List
                    eventListSection
                    
                    // Export Button
                    exportButton
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        loadData()
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
    }
    
    private var userInfoSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("User Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(title: "User ID", value: analyticsService.userId)
                    InfoRow(title: "Analytics Enabled", value: analyticsService.isAnalyticsEnabled ? "Yes" : "No")
                    InfoRow(title: "Install Date", value: analyticsService.installDate.formatted())
                    InfoRow(title: "Session Count", value: "\(analyticsService.sessionCount)")
                    InfoRow(title: "Days Since Install", value: "\(Calendar.current.dateComponents([.day], from: analyticsService.installDate, to: Date()).day ?? 0)")
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Stats")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Divider()
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(title: "Total Events", value: "\(events.count)")
                    StatCard(title: "Water Intakes", value: "\(eventCount(for: "intake_added"))")
                    StatCard(title: "Deletions", value: "\(eventCount(for: "intake_deleted"))")
                    StatCard(title: "Exports", value: "\(eventCount(for: "export_performed"))")
                }
            }
        }
    }
    
    private var eventListSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Recent Events")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Picker("Filter", selection: $selectedEventFilter) {
                        Text("All").tag("All")
                        Text("Intake").tag("intake_added")
                        Text("Session").tag("session")
                        Text("Settings").tag("settings")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Divider()
                
                if filteredEvents.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No events found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(Array(filteredEvents.enumerated()), id: \.offset) { index, event in
                        EventRow(event: event)
                        
                        if index < filteredEvents.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private var exportButton: some View {
        Button(action: exportAnalyticsData) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Analytics Data")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.waterBlue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var filteredEvents: [[String: Any]] {
        if selectedEventFilter == "All" {
            return events.reversed()
        } else if selectedEventFilter == "session" {
            return events.filter { 
                ($0["event_name"] as? String)?.contains("session") ?? false
            }.reversed()
        } else if selectedEventFilter == "settings" {
            return events.filter { 
                ($0["event_name"] as? String)?.contains("settings") ?? false ||
                ($0["event_name"] as? String)?.contains("goal") ?? false ||
                ($0["event_name"] as? String)?.contains("unit") ?? false
            }.reversed()
        } else {
            return events.filter { 
                $0["event_name"] as? String == selectedEventFilter 
            }.reversed()
        }
    }
    
    private func loadData() {
        // Load events
        if let storedEvents = UserDefaults.standard.array(forKey: "analyticsEvents") as? [[String: Any]] {
            events = storedEvents
        }
        
        // Load user properties from UserDefaults
        if let storedProperties = UserDefaults.standard.dictionary(forKey: "analyticsUserProperties") {
            userProperties = storedProperties
        }
    }
    
    private func eventCount(for eventName: String) -> Int {
        return events.filter { ($0["event_name"] as? String) == eventName }.count
    }
    
    private func exportAnalyticsData() {
        analyticsService.trackEvent(.export_performed)
        
        let data: [String: Any] = [
            "export_date": Date().formatted(),
            "user_id": analyticsService.userId,
            "events": events,
            "user_properties": userProperties
        ]
        
        // Convert to JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let fileName = "HydraTrack_Analytics_\(Date().formatted(date: .numeric, time: .omitted)).json"
                
                // Save to temp file
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                try? jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                // Share
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    // Configure popover for iPad
                    if let popover = activityVC.popoverPresentationController {
                        // Get the key window's bounds
                        let bounds = window.bounds
                        // Use the center of the screen as the source
                        popover.sourceView = window
                        popover.sourceRect = CGRect(
                            x: bounds.midX,
                            y: bounds.midY,
                            width: 0,
                            height: 0
                        )
                        popover.permittedArrowDirections = []
                    }
                    
                    rootVC.present(activityVC, animated: true)
                }
            }
        } catch {
            print("Failed to export analytics: \(error)")
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.waterBlue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.waterBlue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EventRow: View {
    let event: [String: Any]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event["event_name"] as? String ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let timestamp = event["timestamp"] as? TimeInterval {
                    Text(Date(timeIntervalSince1970: timestamp).formatted())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if let params = event["parameters"] as? [String: Any], !params.isEmpty {
                Text(params.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboardView()
    }
}