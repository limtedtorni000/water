import SwiftUI

extension Color {
    // Primary colors with dark mode adjustments
    static let waterBlue = Color(red: 61/255, green: 185/255, blue: 255/255)
    static let caffeineBrown = Color(red: 111/255, green: 78/255, blue: 55/255)
    
    // Light backgrounds - reduced opacity for dark mode
    static let waterLight = Color(red: 61/255, green: 185/255, blue: 255/255, opacity: 0.15)
    static let caffeineLight = Color(red: 111/255, green: 78/255, blue: 55/255, opacity: 0.15)
    
    // Insight colors
    static let insightOrange = Color.orange
    static let successGreen = Color.green
    static let warningRed = Color.red
    static let infoBlue = Color.blue
    
    // Use system semantic colors that adapt to light/dark mode
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // Background colors
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
}