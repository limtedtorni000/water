import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            SettingsView(viewModel: IntakeViewModel())
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            
            // Track tab changes
            AnalyticsService.shared.trackScreen("Tab Navigation")
        }
        .onChange(of: selectedTab) { _, newTab in
            let tabNames = ["Home", "History", "Analytics", "Settings"]
            AnalyticsService.shared.trackScreen(tabNames[newTab])
        }
    }
}

#Preview {
    ContentView()
}