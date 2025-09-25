import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: IntakeViewModel
    @EnvironmentObject var subscriptionService: SubscriptionService
    
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var reminderAuthorized = false
    @State private var showPaywall = false
    
    // Temporary values for unit conversion preview
    @State private var tempWaterGoal: Double = 2000
    @State private var tempCaffeineGoal: Double = 400
    @State private var tempWaterUnit: String = "ml"
    @State private var tempCaffeineUnit: String = "mg"
    @State private var hasUnsavedChanges = false
    
    init(viewModel: IntakeViewModel) {
        self.viewModel = viewModel
        self._settingsViewModel = StateObject(wrappedValue: SettingsViewModel(intakeViewModel: viewModel))
    }
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.04, green: 0.04, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    goalsCard
                        .transition(.scale.combined(with: .opacity))
                    
                    remindersCard
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0).delay(0.1), value: settingsViewModel.reminderEnabled)
                    
                    if !subscriptionService.isSubscribed {
                        subscriptionCard
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0).delay(0.15), value: true)
                    }
                    
                    aboutCard
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0).delay(0.2), value: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .onAppear {
            // Load current settings into temp values
            tempWaterGoal = settingsViewModel.waterGoal
            tempCaffeineGoal = settingsViewModel.caffeineGoal
            tempWaterUnit = settingsViewModel.waterUnit
            tempCaffeineUnit = settingsViewModel.caffeineUnit
            hasUnsavedChanges = false
            
            checkReminderAuthorization()
            syncReminderStatus()
        }
    }
    
    // MARK: - Modern Card Components
    
    private var goalsCard: some View {
        VStack(spacing: 0) {
            // Header with Gradient Background
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Daily Goals")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Track your hydration & caffeine")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.leading, 2)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        // Show tips or info
                        triggerHaptic(.light)
                    }
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
            .background(
                LinearGradient(
                    colors: [Color.waterBlue, Color.caffeineBrown],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 16,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 16,
                style: .continuous
            ))
            
            // Content Area
            VStack(spacing: 0) {
                // Circular Progress Section
                HStack(spacing: 24) {
                    // Water Progress Circle
                    circularProgressView(
                        progress: calculateWaterProgress(),
                        color: .waterBlue,
                        icon: "drop.fill",
                        value: Int(getTodayIntake(for: "water")),
                        goal: Int(tempWaterGoal),
                        unit: tempWaterUnit,
                        title: "Water"
                    )
                    
                    Spacer()
                    
                    // Caffeine Progress Circle
                    circularProgressView(
                        progress: calculateCaffeineProgress(),
                        color: .caffeineBrown,
                        icon: "mug.fill",
                        value: Int(getTodayIntake(for: "caffeine")),
                        goal: Int(tempCaffeineGoal),
                        unit: tempCaffeineUnit,
                        title: "Caffeine"
                    )
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 32)
                
                Divider()
                    .padding(.horizontal, 28)
                
                // Goal Adjustment Section
                VStack(spacing: 24) {
                    // Water Goal
                    goalAdjuster(
                        title: "Water Target",
                        icon: "drop",
                        color: .waterBlue,
                        value: Binding(
                            get: { tempWaterGoal },
                            set: { tempWaterGoal = $0; hasUnsavedChanges = true }
                        ),
                        unit: Binding(
                            get: { tempWaterUnit },
                            set: { newValue in
                                // Convert value when unit changes
                                if tempWaterUnit != newValue {
                                    tempWaterGoal = convertWaterValue(tempWaterGoal, from: tempWaterUnit, to: newValue)
                                    tempWaterUnit = newValue
                                    hasUnsavedChanges = true
                                }
                            }
                        ),
                        units: ["ml", "oz"]
                    )
                    
                    // Caffeine Goal
                    goalAdjuster(
                        title: "Caffeine Limit",
                        icon: "mug",
                        color: .caffeineBrown,
                        value: Binding(
                            get: { tempCaffeineGoal },
                            set: { tempCaffeineGoal = $0; hasUnsavedChanges = true }
                        ),
                        unit: Binding(
                            get: { tempCaffeineUnit },
                            set: { newValue in
                                // Convert value when unit changes
                                if tempCaffeineUnit != newValue {
                                    tempCaffeineGoal = convertCaffeineValue(tempCaffeineGoal, from: tempCaffeineUnit, to: newValue)
                                    tempCaffeineUnit = newValue
                                    hasUnsavedChanges = true
                                }
                            }
                        ),
                        units: ["mg", "cups"]
                    )
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 28)
                
                // Quick Actions
                HStack(spacing: 16) {
                    actionButton(
                        title: "Reset Daily",
                        icon: "arrow.counterclockwise",
                        color: .gray,
                        action: {
                            triggerHaptic(.medium)
                            // Reset daily progress logic would go here
                        }
                    )
                    
                    Spacer()
                    
                    actionButton(
                        title: "Apply Presets",
                        icon: "slider.horizontal.3",
                        color: hasUnsavedChanges ? .waterBlue : .gray,
                        action: {
                            applySettings()
                            triggerHaptic(.light)
                        }
                    )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 0,
                    style: .continuous
                )
                .fill(Color(UIColor.secondarySystemBackground))
            )
            .offset(y: -8)
        }
      }
    
      
    private var remindersCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                Text("Reminders")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Enable Reminders")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Toggle("", isOn: $settingsViewModel.reminderEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.waterBlue))
                            .labelsHidden()
                            .onChange(of: settingsViewModel.reminderEnabled) { _, newValue in
                                triggerHaptic(.light)
                                if newValue {
                                    ReminderService.shared.scheduleReminder(type: settingsViewModel.reminderType, interval: TimeInterval(settingsViewModel.reminderInterval * 60))
                                } else {
                                    ReminderService.shared.cancelAllReminders()
                                }
                            }
                    }
                }
                .padding(16)
                .background(Color.secondaryBackground)
                .cornerRadius(16)
                
                if settingsViewModel.reminderEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Reminder Interval")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("\(settingsViewModel.reminderInterval) min")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.waterBlue)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(settingsViewModel.reminderInterval) },
                            set: { settingsViewModel.reminderInterval = Int($0) }
                        ), in: 15...120, step: 15)
                        .accentColor(Color.waterBlue)
                        .tint(Color.waterBlue)
                        .onChange(of: settingsViewModel.reminderInterval) { _, newValue in
                            triggerHaptic(.light)
                            if settingsViewModel.reminderEnabled {
                                ReminderService.shared.scheduleReminder(type: settingsViewModel.reminderType, interval: TimeInterval(newValue * 60))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Reminder Type")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(settingsViewModel.reminderType == .water ? "Water" : settingsViewModel.reminderType == .caffeine ? "Coffee" : "Both")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.waterBlue)
                        }
                        
                        Picker("Reminder Type", selection: $settingsViewModel.reminderType) {
                            ForEach(IntakeType.allCases, id: \.self) { type in
                                Text(type == .water ? "Water" : type == .caffeine ? "Coffee" : "Both")
                                    .tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: settingsViewModel.reminderType) { _, newValue in
                            triggerHaptic(.light)
                            if settingsViewModel.reminderEnabled {
                                ReminderService.shared.scheduleReminder(type: newValue, interval: TimeInterval(settingsViewModel.reminderInterval * 60))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .background(Color.secondaryBackground)
        .cornerRadius(20)
    }
    
    private var subscriptionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                Text("Premium Features")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unlock Premium")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            
                            Text("Get advanced analytics, Smart insights, achievements, and more")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            
                            Text("$0.99/mo")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                
                Button(action: {
                    showPaywall = true
                    triggerHaptic(.medium)
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.subheadline)
                        
                        Text("Upgrade to Premium")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.subheadline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.yellow)
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color.secondaryBackground)
        .cornerRadius(20)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private var aboutCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                Text("About")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Version")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Text("1.0.0")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
                .padding(16)
                .background(Color.secondaryBackground)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Developer")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Text("HydraTrack Team")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
                .padding(16)
                .background(Color.secondaryBackground)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset to Defaults")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            resetSettings()
                            triggerHaptic(.medium)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.subheadline)
                            Text("Reset Settings")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.warningRed)
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(Color.secondaryBackground)
                .cornerRadius(16)
            }
        }
        .padding(20)
        .background(Color.secondaryBackground)
        .cornerRadius(20)
    }
    
      
    @ViewBuilder
    private func circularProgressView(
        progress: Double,
        color: Color,
        icon: String,
        value: Int,
        goal: Int,
        unit: String,
        title: String
    ) -> some View {
        VStack(spacing: 16) {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 10)
                    .frame(width: 110, height: 110)
                
                // Progress Circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                // Center Content
                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                        .scaleEffect(progress > 0.8 ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true), value: progress)
                    
                    Text("\(Int((progress.isFinite && !progress.isNaN) ? progress * 100 : 0))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("\(value) / \(goal) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func goalAdjuster(
        title: String,
        icon: String,
        color: Color,
        value: Binding<Double>,
        unit: Binding<String>,
        units: [String]
    ) -> some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                        .frame(width: 36, height: 36)
                        .background(color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Daily target")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Value Display
                HStack(spacing: 6) {
                    Text("\(Int(value.wrappedValue))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text(unit.wrappedValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Controls
            HStack(spacing: 20) {
                // Minus Button
                Button(action: {
                    if title == "Water Target" {
                        tempWaterGoal = max(minimumValue(for: tempWaterUnit), 
                                            tempWaterGoal - incrementStep(for: tempWaterUnit))
                    } else {
                        tempCaffeineGoal = max(minimumValue(for: tempCaffeineUnit), 
                                               tempCaffeineGoal - incrementStep(for: tempCaffeineUnit))
                    }
                    hasUnsavedChanges = true
                    triggerHaptic(.light)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(color)
                }
                .buttonStyle(.plain)
                
                // Slider
                Slider(
                    value: value,
                    in: minimumValue(for: unit.wrappedValue)...maximumValue(for: unit.wrappedValue),
                    step: incrementStep(for: unit.wrappedValue)
                ) {
                    Text(title)
                }
                
                // Plus Button
                Button(action: {
                    if title == "Water Target" {
                        tempWaterGoal = min(maximumValue(for: tempWaterUnit), 
                                            tempWaterGoal + incrementStep(for: tempWaterUnit))
                    } else {
                        tempCaffeineGoal = min(maximumValue(for: tempCaffeineUnit), 
                                               tempCaffeineGoal + incrementStep(for: tempCaffeineUnit))
                    }
                    hasUnsavedChanges = true
                    triggerHaptic(.light)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(color)
                }
                .buttonStyle(.plain)
            }
            
            // Unit Toggle
            HStack(spacing: 12) {
                ForEach(units, id: \.self) { unitOption in
                    Button(action: {
                        if unit.wrappedValue != unitOption {
                            // Convert value when unit changes
                            if title == "Water Target" {
                                tempWaterGoal = convertWaterValue(tempWaterGoal, from: tempWaterUnit, to: unitOption)
                                tempWaterUnit = unitOption
                            } else {
                                tempCaffeineGoal = convertCaffeineValue(tempCaffeineGoal, from: tempCaffeineUnit, to: unitOption)
                                tempCaffeineUnit = unitOption
                            }
                            hasUnsavedChanges = true
                        }
                        triggerHaptic(.light)
                    }) {
                        Text(unitOption)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(unit.wrappedValue == unitOption ? .white : color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(unit.wrappedValue == unitOption ? color : color.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .scaleEffect(0.98)
        .animation(.easeInOut(duration: 0.1), value: true)
    }
    
    // MARK: - Enhanced Goal Components
    
    @ViewBuilder
    private func enhancedGoalRow(
        title: String,
        subtitle: String,
        value: Binding<Double>,
        unit: Binding<String>,
        units: [String],
        icon: String,
        color: Color,
        progress: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.title3)
                        
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }
                
                Spacer()
                
                // Current Value Display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(value.wrappedValue))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text(unit.wrappedValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 1.5)
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                HStack {
                    Text("Progress: \(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(getTodayIntake(for: title.lowercased()))) / \(Int(value.wrappedValue)) \(unit.wrappedValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Input Controls
            HStack(spacing: 16) {
                // Stepper
                Stepper(
                    onIncrement: {
                        value.wrappedValue += incrementStep(for: unit.wrappedValue)
                        settingsViewModel.saveSettings()
                        triggerHaptic(.light)
                    },
                    onDecrement: {
                        value.wrappedValue = max(minimumValue(for: unit.wrappedValue), value.wrappedValue - incrementStep(for: unit.wrappedValue))
                        settingsViewModel.saveSettings()
                        triggerHaptic(.light)
                    },
                    label: { EmptyView() }
                )
                .labelsHidden()
                
                // TextField
                TextField("Amount", value: value, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
                    .onChange(of: value.wrappedValue) { _, _ in
                        settingsViewModel.saveSettings()
                    }
                
                // Unit Picker
                Menu {
                    ForEach(units, id: \.self) { unitOption in
                        Button(unitOption) {
                            unit.wrappedValue = unitOption
                            settingsViewModel.saveSettings()
                            triggerHaptic(.light)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(unit.wrappedValue)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func presetButton(title: String, water: Double, caffeine: Double) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tempWaterGoal = water
                tempCaffeineGoal = caffeine
                hasUnsavedChanges = true
                triggerHaptic(.medium)
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.waterBlue)
                        Text("\(Int(tempWaterUnit == "oz" ? convertWaterValue(water, from: "ml", to: "oz") : water)) \(tempWaterUnit)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mug.fill")
                            .font(.caption)
                            .foregroundColor(.caffeineBrown)
                        Text("\(Int(tempCaffeineUnit == "cups" ? convertCaffeineValue(caffeine, from: "mg", to: "cups") : caffeine)) \(tempCaffeineUnit)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tempWaterGoal == water && tempCaffeineGoal == caffeine ? 
                          AnyShapeStyle(LinearGradient(
                            colors: [Color.waterBlue.opacity(0.2), Color.caffeineBrown.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )) : 
                          AnyShapeStyle(Color(UIColor.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tempWaterGoal == water && tempCaffeineGoal == caffeine ? 
                                   Color.waterBlue : 
                                   Color.clear, 
                                   lineWidth: 2)
                    )
            )
            .scaleEffect(tempWaterGoal == water && tempCaffeineGoal == caffeine ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tempWaterGoal)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Progress Calculation Helpers
    
    private func calculateWaterProgress() -> Double {
        let todayIntake = getTodayIntake(for: "water")
        let goal = tempWaterGoal
        return goal > 0 ? min(todayIntake / goal, 1.0) : 0
    }
    
    private func calculateCaffeineProgress() -> Double {
        let todayIntake = getTodayIntake(for: "caffeine")
        let goal = tempCaffeineGoal
        return goal > 0 ? min(todayIntake / goal, 1.0) : 0
    }
    
    private func getTodayIntake(for type: String) -> Double {
        // Get today's entries from IntakeViewModel
        let targetType = type == "water" ? "water" : "caffeine"
        return viewModel.todayEntries
            .filter { $0.type == targetType }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Value Helpers
    
    private func convertWaterValue(_ value: Double, from fromUnit: String, to toUnit: String) -> Double {
        // Convert to ml first, then to target unit
        let inML = fromUnit == "oz" ? value * 29.5735 : value
        return toUnit == "oz" ? inML / 29.5735 : inML
    }
    
    private func convertCaffeineValue(_ value: Double, from fromUnit: String, to toUnit: String) -> Double {
        // Convert to mg first, then to target unit (assuming 1 cup = 95mg caffeine)
        let inMG = fromUnit == "cups" ? value * 95 : value
        return toUnit == "cups" ? inMG / 95 : inMG
    }
    
    private func incrementStep(for unit: String) -> Double {
        switch unit {
        case "ml": return 100
        case "oz": return 4
        case "mg": return 50
        case "cups": return 0.5
        default: return 1
        }
    }
    
    private func minimumValue(for unit: String) -> Double {
        switch unit {
        case "ml": return 500
        case "oz": return 16
        case "mg": return 0
        case "cups": return 0
        default: return 0
        }
    }
    
    private func maximumValue(for unit: String) -> Double {
        switch unit {
        case "ml": return 5000
        case "oz": return 160
        case "mg": return 1000
        case "cups": return 10
        default: return 1000
        }
    }
    
    // MARK: - Original Helper Components
    
    @ViewBuilder
    private func goalInputRow(
        title: String,
        value: Binding<Double>,
        unit: Binding<String>,
        units: [String],
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                TextField("Amount", value: value, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .onChange(of: value.wrappedValue) { _, _ in
                        settingsViewModel.saveSettings()
                    }
                
                Picker("", selection: unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 60)
            }
        }
    }
    
    @ViewBuilder
    private func toggleUnitRow(
        title: String,
        value: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            action()
            triggerHaptic(.light)
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .scaleEffect(0.98)
        .animation(.easeInOut(duration: 0.1), value: true)
    }
    
    // MARK: - Computed Properties
    
    private var reminderIntervalText: String {
        switch settingsViewModel.reminderInterval {
        case 30: return "30 minutes"
        case 60: return "1 hour"
        case 120: return "2 hours"
        case 180: return "3 hours"
        default: return "\(settingsViewModel.reminderInterval) minutes"
        }
    }
    
    // MARK: - Helper Functions
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            if reminderAuthorized {
                ReminderService.shared.scheduleHydrationReminder(
                    interval: TimeInterval(settingsViewModel.reminderInterval * 60)
                )
                // Verify the reminder was actually scheduled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ReminderService.shared.getPendingReminders { reminders in
                        if reminders.isEmpty {
                            // If no reminders are pending, there was an error
                            settingsViewModel.reminderEnabled = false
                        }
                    }
                }
            } else {
                settingsViewModel.reminderEnabled = false
            }
        } else {
            ReminderService.shared.cancelAllReminders()
        }
    }
    
    private func checkReminderAuthorization() {
        ReminderService.shared.checkNotificationStatus { authorized in
            reminderAuthorized = authorized
        }
    }
    
    private func syncReminderStatus() {
        // Check if reminders are actually scheduled and sync with UI
        ReminderService.shared.getPendingReminders { reminders in
            DispatchQueue.main.async {
                let hasPendingReminder = !reminders.isEmpty
                let reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
                
                // If UI shows enabled but no reminder is scheduled, disable it
                if reminderEnabled && !hasPendingReminder {
                    settingsViewModel.reminderEnabled = false
                    UserDefaults.standard.set(false, forKey: "reminderEnabled")
                }
                // If UI shows disabled but reminder is scheduled, cancel it
                else if !reminderEnabled && hasPendingReminder {
                    ReminderService.shared.cancelAllReminders()
                }
            }
        }
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
        
        // Check authorization status after returning from settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            checkReminderAuthorization()
            syncReminderStatus()
        }
    }
    
    private func resetSettings() {
        // Reset to defaults
        tempWaterGoal = 2000
        tempCaffeineGoal = 400
        tempWaterUnit = "ml"
        tempCaffeineUnit = "mg"
        hasUnsavedChanges = true
        
        // Apply immediately
        applySettings()
        
        if settingsViewModel.reminderEnabled && reminderAuthorized {
            ReminderService.shared.scheduleHydrationReminder(
                interval: TimeInterval(settingsViewModel.reminderInterval * 60)
            )
        }
    }
    
    private func applySettings() {
        // Apply temporary settings
        settingsViewModel.waterGoal = tempWaterGoal
        settingsViewModel.caffeineGoal = tempCaffeineGoal
        settingsViewModel.waterUnit = tempWaterUnit
        settingsViewModel.caffeineUnit = tempCaffeineUnit
        settingsViewModel.saveSettings()
        hasUnsavedChanges = false
    }
}

#Preview {
    SettingsView(viewModel: IntakeViewModel.shared)
        .environmentObject(SubscriptionService.shared)
}