//
//  PremiumOverlay.swift
//  HydraTrack
//
//  Created by GH on 25/9/2025.
//

import SwiftUI

struct PremiumOverlay: View {
    let title: String
    let description: String
    let onUpgrade: () -> Void
    
    var body: some View {
        ZStack {
            // Blurred background
            Rectangle()
                .fill(Color.black.opacity(0.7))
                .blur(radius: 20)
            
            VStack(spacing: 20) {
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                
                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Description
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Upgrade button
                Button(action: onUpgrade) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Unlock Premium")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Feature list
                VStack(alignment: .leading, spacing: 8) {
                    FeatureCheckmark(text: "Advanced analytics & charts")
                    FeatureCheckmark(text: "Smart-powered insights")
                    FeatureCheckmark(text: "Achievement system")
                    FeatureCheckmark(text: "Data export")
                    FeatureCheckmark(text: "7-day free trial")
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(24)
        }
    }
}

struct FeatureCheckmark: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.subheadline)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}