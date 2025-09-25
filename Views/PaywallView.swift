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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get the most out of HydraTrack with advanced features")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Detailed charts and trend analysis")
                        FeatureRow(icon: "brain.head.profile", title: "Smart Insights", description: "Personalized recommendations")
                        FeatureRow(icon: "trophy.fill", title: "Achievements", description: "Track your progress with badges")
                        FeatureRow(icon: "square.and.arrow.down", title: "Export Data", description: "CSV export for further analysis")
                        FeatureRow(icon: "infinity", title: "Unlimited History", description: "Keep all your data forever")
                        FeatureRow(icon: "bell.badge.fill", title: "Advanced Reminders", description: "Smart notification scheduling")
                    }
                    .padding(.horizontal)
                    
                    // Products
                    VStack(spacing: 12) {
                        if subscriptionService.isLoadingProducts {
                            ProgressView()
                                .padding()
                        } else {
                            ForEach(subscriptionService.products) { product in
                                ProductCard(product: product) {
                                    Task {
                                        await subscriptionService.purchase(product)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Restore button
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionService.restorePurchases()
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                    
                    // Footer links
                    VStack(spacing: 8) {
                        Button("Privacy Policy") {
                            showPrivacyPolicy = true
                        }
                        .font(.footnote)
                        
                        Button("Terms of Service") {
                            showTermsOfService = true
                        }
                        .font(.footnote)
                        
                        Text("Subscription automatically renews unless cancelled. You can manage your subscription in App Store settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
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
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ProductCard: View {
    let product: Product
    let onPurchase: () -> Void
    
    var body: some View {
        Button(action: onPurchase) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                let trialText = SubscriptionService.shared.getTrialPeriodText(for: product)
                if !trialText.isEmpty {
                    Text(trialText)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if product.type == .autoRenewable {
                        Text("per month")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .disabled(SubscriptionService.shared.isPurchasing)
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