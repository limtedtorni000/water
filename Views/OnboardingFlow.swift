//
//  OnboardingFlow.swift
//  HydraTrack
//
//  Created by GH on 25/9/2025.
//

import SwiftUI

struct OnboardingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var currentPage = 0
    @State private var showPaywall = false
    @State private var animateTransition = false
    
    private let totalPages = 4
    
    var body: some View {
        ZStack {
            if showPaywall {
                PaywallView(isOnboarding: true, onDismiss: completeOnboarding)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Skip button
                        if currentPage < totalPages - 1 {
                            HStack {
                                Spacer()
                                Button("Skip") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showPaywall = true
                                    }
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 16)
                                .padding(.trailing, 24)
                            }
                        } else {
                            Spacer()
                                .frame(height: 60)
                        }
                        
                        // Page content
                        TabView(selection: $currentPage) {
                            OnboardingPage1()
                                .tag(0)
                            
                            OnboardingPage2()
                                .tag(1)
                            
                            OnboardingPage3()
                                .tag(2)
                            
                            OnboardingPage4()
                                .tag(3)
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                        .frame(height: geometry.size.height * 0.6)
                        
                        Spacer()
                        
                        // Navigation buttons
                        VStack(spacing: 20) {
                            if currentPage < totalPages - 1 {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                }) {
                                    HStack {
                                        Text("Next")
                                            .font(.system(size: 18, weight: .semibold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                }
                                .padding(.horizontal, 24)
                            } else {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showPaywall = true
                                    }
                                }) {
                                    HStack {
                                        Text("Get Started")
                                            .font(.system(size: 18, weight: .semibold))
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                }
                                .padding(.horizontal, 24)
                            }
                          }
                    }
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.15),
                            Color(red: 0.05, green: 0.05, blue: 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .onChange(of: showPaywall) { _ in
            if !showPaywall {
                // User closed paywall without subscribing
                completeOnboarding()
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Onboarding Pages

struct OnboardingPage1: View {
    @State private var animateDrop = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated water drop
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(animateDrop ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateDrop)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.blue)
                    .scaleEffect(animateDrop ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateDrop)
            }
            
            VStack(spacing: 16) {
                Text("Welcome to HydraTrack")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                
                Text("Your personal hydration companion that helps you stay healthy and energized")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
            }
            
            Spacer()
        }
        .onAppear {
            animateDrop = true
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                animateText = true
            }
        }
    }
}

struct OnboardingPage2: View {
    @State private var animateCards = false
    @State private var cardOffsets: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Track Everything")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Log water, coffee, tea, and more with our intuitive tracking system")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 20) {
                // Animated cards
                ForEach(0..<2, id: \.self) { index in
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: ["drop.fill", "mug.fill"][index])
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor([.blue, .brown][index])
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(["Water", "Coffee"][index])
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(["250ml", "180ml"][index])
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text("Log")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(y: animateCards ? 0 : CGFloat(index * 20))
                    .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateCards)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .onAppear {
            animateCards = true
        }
    }
}

struct OnboardingPage3: View {
    @State private var animateChart = false
    @State private var animateInsights = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Gain Insights")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Understand your hydration patterns with beautiful analytics")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Mock chart visualization
            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.6)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 30, height: CGFloat([30, 50, 70, 60, 80, 90, 85][index]))
                                .cornerRadius(4)
                                .scaleEffect(y: animateChart ? 1.0 : 0.0, anchor: .bottom)
                                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: animateChart)
                            
                            Text(["M", "T", "W", "T", "F", "S", "S"][index])
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Insight card
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.yellow)
                    
                    Text("You're most hydrated on weekends!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.2))
                )
                .opacity(animateInsights ? 1.0 : 0.0)
                .offset(y: animateInsights ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: animateInsights)
            }
            
            Spacer()
        }
        .onAppear {
            animateChart = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                animateInsights = true
            }
        }
    }
}

struct OnboardingPage4: View {
    @State private var animateFeatures = false
    @State private var featureOpacities: [Double] = [0, 0, 0]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Stay on Track")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Never miss your hydration goals with smart reminders")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "bell.fill",
                    title: "Smart Reminders",
                    description: "Get notified when it's time to hydrate",
                    color: .blue,
                    opacity: featureOpacities[0]
                )
                
                FeatureRow(
                    icon: "target",
                    title: "Daily Goals",
                    description: "Set and track your daily water intake targets",
                    color: .green,
                    opacity: featureOpacities[1]
                )
                
                FeatureRow(
                    icon: "calendar",
                    title: "Weekly Summary",
                    description: "Review your progress with weekly reports",
                    color: .purple,
                    opacity: featureOpacities[2]
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .onAppear {
            animateFeatures = true
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                featureOpacities[0] = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                featureOpacities[1] = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                featureOpacities[2] = 1.0
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let opacity: Double
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
        .opacity(opacity)
    }
}

#Preview {
    OnboardingFlow()
        .environmentObject(SubscriptionService.shared)
}