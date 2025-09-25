//
//  PaywallView.swift
//  HydraTrack
//
//  Created by GH on 25/9/2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var selectedProduct: Product?
    @State private var animateGradient = false
    @State private var showFeatures = false
    @State private var featureOpacity = 0.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero section with animated gradient
                        heroSection
                            .frame(height: geometry.size.height * 0.28)
                        
                        // Features section
                        featuresSection
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                        
                        // Pricing section
                        pricingSection
                            .padding(.horizontal, 24)
                            .padding(.top, 28)
                        
                        // Footer
                        footerSection
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                }
                .background(Color(.systemBackground))
                .ignoresSafeArea()
            }
            .navigationBarHidden(true)
            .alert("Subscription", isPresented: $subscriptionService.showAlert) {
                Button("OK") { }
            } message: {
                Text(subscriptionService.alertMessage)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                SafariView(url: URL(string: "https://hydratrack.app/privacy")!)
            }
            .sheet(isPresented: $showTermsOfService) {
                SafariView(url: URL(string: "https://hydratrack.app/terms")!)
            }
            .task {
                await subscriptionService.loadProducts()
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack {
            // Multi-layer gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.4, blue: 0.95),
                    Color(red: 0.3, green: 0.2, blue: 0.9),
                    Color(red: 0.6, green: 0.3, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(animateGradient ? 30 : 0))
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)
            .onAppear {
                animateGradient = true
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    showFeatures = true
                    featureOpacity = 1.0
                }
            }
            
            // Subtle pattern overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.03))
                            .frame(width: 80, height: 80)
                            .offset(x: CGFloat(i * 30 - 60), y: 40)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 16) {
                // App icon and title
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("HydraTrack")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .scaleEffect(animateGradient ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
                
                VStack(spacing: 4) {
                    Text("Unlock Premium")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Text("Everything you need to master hydration")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                
                // Social proof badges
                HStack(spacing: 8) {
                    SocialBadge(icon: "star.fill", text: "4.8 Rating")
                    SocialBadge(icon: "person.2.fill", text: "50K+ Users")
                    SocialBadge(icon: "shield.fill", text: "Secure")
                }
                .opacity(featureOpacity)
                
                // Close button
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
            }
            .padding(.top, 40)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Premium Features")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Upgrade your hydration experience")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .opacity(featureOpacity)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                EnhancedFeatureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Analytics",
                    description: "Detailed insights into your hydration patterns",
                    color: .blue
                )
                
                EnhancedFeatureCard(
                    icon: "brain.head.profile",
                    title: "Smart Insights",
                    description: "AI-powered recommendations",
                    color: .purple
                )
                
                EnhancedFeatureCard(
                    icon: "trophy.fill",
                    title: "Achievements",
                    description: "Gamified progress tracking",
                    color: .orange
                )
                
                EnhancedFeatureCard(
                    icon: "square.and.arrow.down",
                    title: "Export Data",
                    description: "CSV export for analysis",
                    color: .green
                )
                
                EnhancedFeatureCard(
                    icon: "infinity",
                    title: "Unlimited History",
                    description: "Never lose your data",
                    color: .indigo
                )
                
                EnhancedFeatureCard(
                    icon: "bell.badge.fill",
                    title: "Smart Reminders",
                    description: "Intelligent notifications",
                    color: .pink
                )
            }
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Choose Your Plan")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("7-day free trial • Cancel anytime")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .opacity(featureOpacity)
            
            if subscriptionService.isLoadingProducts {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading plans...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ForEach(subscriptionService.products) { product in
                    ModernProductCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        isPopular: product.type == .autoRenewable,
                        onTap: {
                            selectedProduct = product
                            Task {
                                await subscriptionService.purchase(product)
                            }
                        }
                    )
                    .opacity(featureOpacity)
                }
            }
            
            VStack(spacing: 12) {
                Button("Restore Purchases") {
                    Task {
                        await subscriptionService.restorePurchases()
                    }
                }
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Secure payment powered by Apple")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                Button("Privacy Policy") {
                    showPrivacyPolicy = true
                }
                .font(.footnote)
                .foregroundColor(.blue)
                
                Button("Terms of Service") {
                    showTermsOfService = true
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            Text("Subscription auto-renews unless cancelled. Manage anytime in App Store settings.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// Modern Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// Modern Product Option Card
struct ProductOptionCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(product.description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if product.type == .autoRenewable {
                            Text("per month")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Trial badge
                let trialText = SubscriptionService.shared.getTrialPeriodText(for: product)
                if !trialText.isEmpty {
                    HStack {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text(trialText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.15))
                    )
                }
                
                // CTA Button
                HStack {
                    Text(product.type == .autoRenewable ? "Start Free Trial" : "Unlock Lifetime")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? Color.blue.opacity(0.05) : Color(.secondarySystemBackground))
                    )
                    .shadow(color: isSelected ? Color.blue.opacity(0.2) : .black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
            )
        }
        .disabled(SubscriptionService.shared.isPurchasing)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// Social Proof Badge Component
struct SocialBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

// Enhanced Feature Card Component
struct EnhancedFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.green)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
    }
}

// Modern Product Card Component
struct ModernProductCard: View {
    let product: Product
    let isSelected: Bool
    let isPopular: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Popular badge
                if isPopular {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("MOST POPULAR")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.orange)
                            .tracking(1.2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                }
                
                VStack(spacing: 12) {
                    // Product name
                    Text(product.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Price
                    VStack(spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.primary)
                        
                        if product.type == .autoRenewable {
                            HStack(spacing: 4) {
                                Text("then")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text("$0.99/month")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Trial badge
                    let trialText = SubscriptionService.shared.getTrialPeriodText(for: product)
                    if !trialText.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "gift")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text(trialText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // CTA Button
                    HStack {
                        Spacer()
                        
                        if product.type == .autoRenewable {
                            Text("Start Free Trial")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Text("Unlock Lifetime")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        product.type == .autoRenewable 
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            : AnyShapeStyle(Color(.tertiarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(product.type == .autoRenewable ? Color.clear : Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? Color.blue.opacity(0.05) : Color(.tertiarySystemBackground))
                    )
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.25) : .black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
                    )
            )
        }
        .disabled(SubscriptionService.shared.isPurchasing)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// Simple Safari view for external links
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}