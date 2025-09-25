import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            // Global background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(1)
                
                SettingsView(viewModel: IntakeViewModel.shared)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
        }
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            
            // Check if first launch and not subscribed
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") && !subscriptionService.isSubscribed {
                showOnboarding = true
            }
            
            // Listen for onboarding reset notification
            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowOnboarding"),
                object: nil,
                queue: .main
            ) { _ in
                if !subscriptionService.isSubscribed {
                    showOnboarding = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowOnboarding"))) { _ in
            if !subscriptionService.isSubscribed {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlow()
                .environmentObject(subscriptionService)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SubscriptionService.shared)
}