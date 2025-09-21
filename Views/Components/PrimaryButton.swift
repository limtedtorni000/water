import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let icon: String?
    
    enum ButtonStyle {
        case primary
        case secondary
        case water
        case caffeine
    }
    
    init(title: String, style: ButtonStyle = .primary, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.bodyBold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .waterBlue
        case .secondary:
            return .secondaryBackground
        case .water:
            return .waterLight
        case .caffeine:
            return .caffeineLight
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .waterBlue
        case .water:
            return .waterBlue
        case .caffeine:
            return .caffeineBrown
        }
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PrimaryButton(title: "Add Water", style: .water, icon: "drop.fill") {}
            
            PrimaryButton(title: "Add Caffeine", style: .caffeine, icon: "mug.fill") {}
            
            PrimaryButton(title: "Save", style: .primary) {}
            
            PrimaryButton(title: "Cancel", style: .secondary) {}
        }
        .padding()
    }
}