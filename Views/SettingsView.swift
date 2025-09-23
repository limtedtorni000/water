import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: IntakeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var reminderAuthorized = false
    @State private var showingAnalyticsDashboard = false
    
    init(viewModel: IntakeViewModel) {
        self.viewModel = viewModel
        self._settingsViewModel = StateObject(wrappedValue: SettingsViewModel(intakeViewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient with custom dark mode color
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.05, green: 0.05, blue: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Form {
                    goalsSection
                    
                    unitsSection
                    
                    remindersSection
                    
                    analyticsSection
                    
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkReminderAuthorization()
                
                // Configure form appearance for dark mode
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
                
                // Configure title text attributes
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                    .foregroundColor: UIColor.label
                ]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .sheet(isPresented: $showingAnalyticsDashboard) {
                AnalyticsDashboardView()
            }
        }
    }
    
    private var goalsSection: some View {
        Section(header: Text("Daily Goals")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Water Goal")
                    .font(.subheadline)
                
                HStack {
                    TextField("Amount", value: $settingsViewModel.waterGoal, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .onChange(of: settingsViewModel.waterGoal) { _, _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    Picker("", selection: $settingsViewModel.waterUnit) {
                        Text("ml").tag("ml")
                        Text("oz").tag("oz")
                    }
                    .pickerStyle(.menu)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Caffeine Goal")
                    .font(.subheadline)
                
                HStack {
                    TextField("Amount", value: $settingsViewModel.caffeineGoal, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .onChange(of: settingsViewModel.caffeineGoal) { _, _ in
                            settingsViewModel.saveSettings()
                        }
                    
                    Picker("", selection: $settingsViewModel.caffeineUnit) {
                        Text("mg").tag("mg")
                        Text("cups").tag("cups")
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
    
    private var unitsSection: some View {
        Section(header: Text("Units")) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Water Unit")
                    Spacer()
                    Text(settingsViewModel.waterUnit)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    settingsViewModel.waterUnit = settingsViewModel.waterUnit == "ml" ? "oz" : "ml"
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Caffeine Unit")
                    Spacer()
                    Text(settingsViewModel.caffeineUnit)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    settingsViewModel.caffeineUnit = settingsViewModel.caffeineUnit == "mg" ? "cups" : "mg"
                }
            }
        }
    }
    
    private var remindersSection: some View {
        Section(header: Text("Reminders")) {
            Toggle("Hydration Reminders", isOn: $settingsViewModel.reminderEnabled)
                .onChange(of: settingsViewModel.reminderEnabled) { enabled in
                    if enabled {
                        if reminderAuthorized {
                            ReminderService.shared.scheduleHydrationReminder(
                                interval: TimeInterval(settingsViewModel.reminderInterval * 60)
                            )
                        } else {
                            settingsViewModel.reminderEnabled = false
                        }
                    } else {
                        ReminderService.shared.cancelAllReminders()
                    }
                }
            
            if settingsViewModel.reminderEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remind me every")
                        .font(.subheadline)
                    
                    Picker("", selection: $settingsViewModel.reminderInterval) {
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("2 hours").tag(120)
                        Text("3 hours").tag(180)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settingsViewModel.reminderInterval) { _ in
                        if settingsViewModel.reminderEnabled && reminderAuthorized {
                            ReminderService.shared.scheduleHydrationReminder(
                                interval: TimeInterval(settingsViewModel.reminderInterval * 60)
                            )
                        }
                    }
                }
            }
            
            if !reminderAuthorized {
                Button(action: openSettings) {
                    Text("Enable Notifications in Settings")
                        .foregroundColor(.waterBlue)
                }
            }
        }
    }
    
    private var analyticsSection: some View {
        Section(header: Text("Analytics")) {
            Toggle("Share Usage Data", isOn: Binding(
                get: { AnalyticsService.shared.isAnalyticsEnabled },
                set: { AnalyticsService.shared.isAnalyticsEnabled = $0 }
            ))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Help improve HydraTrack by sharing anonymous usage data.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("We never collect personal information.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { showingAnalyticsDashboard = true }) {
                    Text("View Analytics Dashboard")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.waterBlue)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Button(action: resetSettings) {
                Text("Reset to Defaults")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func checkReminderAuthorization() {
        ReminderService.shared.checkNotificationStatus { authorized in
            reminderAuthorized = authorized
        }
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    private func resetSettings() {
        settingsViewModel.resetToDefaults()
        if settingsViewModel.reminderEnabled && reminderAuthorized {
            ReminderService.shared.scheduleHydrationReminder(
                interval: TimeInterval(settingsViewModel.reminderInterval * 60)
            )
        }
    }
}

#Preview {
    SettingsView(viewModel: IntakeViewModel())
}