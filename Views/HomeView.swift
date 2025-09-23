import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = IntakeViewModel.shared
    @State private var showingAddIntake = false
    @State private var animateProgress = false
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Custom Header to match the image layout
                        HStack {
                            Text("HydraTrack")
                                .font(.largeTitle.weight(.bold))
                            
                            Spacer()
                            
                            Button(action: { showingAddIntake = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Header with greeting
                        greetingSection
                        
                        // Progress cards with modern design
                        progressSection
                        
                        // Quick add section with enhanced buttons
                        quickAddSection
                        
                        // Today's entries with better layout
                        if !viewModel.todayEntries.isEmpty {
                            todayEntriesSection
                        }
                        
                        // Bottom spacing for safe area and tab bar
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top) // Provides default top padding below the status bar
                }
            }
            .navigationBarHidden(true) // Hides the original navigation bar
            .sheet(isPresented: $showingAddIntake) {
                AddIntakeView(viewModel: viewModel)
            }
              .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateProgress = true
                }
            }
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        ModernCard(
            padding: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20)
        ) {
            VStack(alignment: .leading, spacing: 10) {
                AppTitleView(
                    title: greeting,
                    subtitle: currentDate
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        HStack(spacing: 16) {
            // Water Progress Card
            ModernCard(
                padding: EdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12)
            ) {
                VStack(spacing: 16) {
                    ZStack {
                        ProgressRing(
                            progress: animateProgress ? viewModel.waterProgress : 0,
                            color: .waterBlue
                        )
                        
                        VStack(spacing: 6) {
                            Text("\(String(format: "%.0f", animateProgress ? viewModel.waterProgress * 100 : 0))%")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.waterBlue)
                                .contentTransition(.numericText())
                            
                            Text("Water")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                    }
                    
                    VStack(spacing: 6) {
                        Text(waterIntake)
                            .font(.system(size: 24, weight: .semibold))
                        
                        HStack(spacing: 4) {
                            Text("of \(String(format: "%.0f", viewModel.waterGoal))")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.waterUnit)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Caffeine Progress Card
            ModernCard(
                padding: EdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12)
            ) {
                VStack(spacing: 16) {
                    ZStack {
                        ProgressRing(
                            progress: animateProgress ? viewModel.caffeineProgress : 0,
                            color: .caffeineBrown
                        )
                        
                        VStack(spacing: 6) {
                            Text("\(String(format: "%.0f", animateProgress ? viewModel.caffeineProgress * 100 : 0))%")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.caffeineBrown)
                                .contentTransition(.numericText())
                            
                            Text("Caffeine")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                    }
                    
                    VStack(spacing: 6) {
                        Text(caffeineIntake)
                            .font(.system(size: 24, weight: .semibold))
                        
                        HStack(spacing: 4) {
                            Text("of \(String(format: "%.0f", viewModel.caffeineGoal))")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.caffeineUnit)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }
    
    private var waterIntake: String {
        let amount = viewModel.todayEntries
            .filter { StorageService.shared.getIntakeType(for: $0) == .water }
            .reduce(0) { $0 + $1.amount }
        return String(format: "%.0f", amount)
    }
    
    private var caffeineIntake: String {
        let amount = viewModel.todayEntries
            .filter { StorageService.shared.getIntakeType(for: $0) == .caffeine }
            .reduce(0) { $0 + $1.amount }
        return String(format: "%.0f", amount)
    }
    
    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        ModernCard(
            padding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        ) {
            VStack(spacing: 20) {
                HStack {
                    Text("Quick Add")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { showingAddIntake = true }) {
                        Text("Custom")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.waterBlue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.waterBlue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 16) {
                    // Water Quick Add Button
                    Button(action: {
                        viewModel.addIntake(type: .water, amount: viewModel.waterUnit == "ml" ? 250 : 8)
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.waterBlue.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.waterBlue)
                            }
                            
                            Text("Water")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(viewModel.waterUnit == "ml" ? "250ml" : "8oz")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.regularMaterial)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Caffeine Quick Add Button
                    Button(action: {
                        viewModel.addIntake(type: .caffeine, amount: viewModel.caffeineUnit == "mg" ? 95 : 1)
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.caffeineBrown.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: "mug.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.caffeineBrown)
                            }
                            
                            Text("Caffeine")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(viewModel.caffeineUnit == "mg" ? "95mg" : "1 cup")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.regularMaterial)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Today's Entries Section
    private var todayEntriesSection: some View {
        ModernCard(
            padding: EdgeInsets(top: 20, leading: 20, bottom: 16, trailing: 20)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Today's Entries")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(viewModel.todayEntries.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                if viewModel.todayEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "drop")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("No entries yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Start tracking your intake")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.todayEntries.enumerated()), id: \.element.objectID) { index, entry in
                            EntryRow(
                                entry: entry,
                                viewModel: viewModel,
                                timeFormatter: timeFormatter
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.todayEntries.count)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Entry Row Component
struct EntryRow: View {
    let entry: IntakeEntry
    let viewModel: IntakeViewModel
    let timeFormatter: DateFormatter
    @State private var isDeleting = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(intakeType.rawValue.capitalized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(timeString)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(amountString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(unitString)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Delete button
            Button(action: {
                withAnimation(.easeInOut) {
                    isDeleting = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.deleteEntry(entry)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
            .opacity(isDeleting ? 0 : 1)
            .scaleEffect(isDeleting ? 0.8 : 1)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
        )
    }
    
    private var intakeType: IntakeType {
        StorageService.shared.getIntakeType(for: entry)
    }
    
    private var iconColor: Color {
        intakeType == .water ? .waterBlue : .caffeineBrown
    }
    
    private var iconName: String {
        intakeType == .water ? "drop.fill" : "mug.fill"
    }
    
    private var timeString: String {
        timeFormatter.string(from: entry.date ?? Date())
    }
    
    private var amountString: String {
        String(format: "%.0f", entry.amount)
    }
    
    private var unitString: String {
        intakeType == .water ? viewModel.waterUnit : viewModel.caffeineUnit
    }
}

#Preview {
    HomeView()
}