import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                timeRangeSelector
                
                if !selectedTimeRangeData.isEmpty {
                    chartView
                    
                    statsView
                } else {
                    emptyStateView
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingExportSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                exportSheet
            }
        }
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            Text("Week").tag(HistoryViewModel.TimeRange.week)
            Text("Month").tag(HistoryViewModel.TimeRange.month)
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: viewModel.selectedTimeRange) {
            viewModel.loadData()
        }
    }
    
    private var selectedTimeRangeData: [HistoryViewModel.DailyIntake] {
        viewModel.selectedTimeRange == .week ? viewModel.weeklyData : viewModel.monthlyData
    }
    
    private var chartView: some View {
        VStack(spacing: 16) {
            Text("Daily Intake")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Chart {
                ForEach(selectedTimeRangeData) { day in
                    BarMark(
                        x: .value("Date", formatDay(day.date)),
                        y: .value("Water", day.waterAmount)
                    )
                    .foregroundStyle(Color.waterBlue)
                    
                    BarMark(
                        x: .value("Date", formatDay(day.date)),
                        y: .value("Caffeine", day.caffeineAmount)
                    )
                    .foregroundStyle(Color.caffeineBrown)
                }
            }
            .frame(height: 200)
            
            HStack {
                HStack {
                    Rectangle()
                        .fill(Color.waterBlue)
                        .frame(width: 12, height: 12)
                    Text("Water")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                HStack {
                    Rectangle()
                        .fill(Color.caffeineBrown)
                        .frame(width: 12, height: 12)
                    Text("Caffeine")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                }
            }
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            Text("Averages")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(String(format: "%.0f", viewModel.getAverageWater())) ml")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.waterBlue)
                    
                    Text("Daily Water")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Text("\(String(format: "%.0f", viewModel.getAverageCaffeine())) mg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.caffeineBrown)
                    
                    Text("Daily Caffeine")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No data yet")
                .font(.headline)
                .foregroundColor(.textSecondary)
            
            Text("Start tracking your water and caffeine intake to see your history here")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var exportSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Data")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Export your intake history as a CSV file")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                PrimaryButton(
                    title: "Export CSV",
                    style: .primary,
                    icon: "square.and.arrow.up"
                ) {
                    exportCSV()
                }
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showingExportSheet = false
                    }
                }
            }
        }
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        if viewModel.selectedTimeRange == .week {
            formatter.dateFormat = "E"
        } else {
            formatter.dateFormat = "MM/dd"
        }
        return formatter.string(from: date)
    }
    
    private func exportCSV() {
        let csv = StorageService.shared.exportToCSV()
        
        if let data = csv.data(using: .utf8) {
            let fileName = "HydraTrack_Export_\(Date().formatted(date: .numeric, time: .omitted)).csv"
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = window
                        popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    }
                    
                    rootVC.present(activityVC, animated: true)
                }
                
                showingExportSheet = false
            } catch {
                print("Failed to export CSV: \(error)")
            }
        }
    }
}

#Preview {
    HistoryView()
}