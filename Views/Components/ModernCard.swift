import SwiftUI

struct ModernCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: EdgeInsets
    
    init(
        style: CardStyle = .default,
        padding: EdgeInsets = EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(
                        color: style.shadowColor,
                        radius: style.shadowRadius,
                        x: 0,
                        y: style.shadowY
                    )
            )
    }
    
    enum CardStyle {
        case `default`
        case elevated
        case glass
        case flat
        
        var shadowRadius: CGFloat {
            switch self {
            case .default: return 16
            case .elevated: return 32
            case .glass: return 0
            case .flat: return 0
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .default: return .black.opacity(0.15)
            case .elevated: return .black.opacity(0.25)
            case .glass: return .clear
            case .flat: return .clear
            }
        }
        
        var shadowY: CGFloat {
            switch self {
            case .default: return 6
            case .elevated: return 12
            case .glass: return 0
            case .flat: return 0
            }
        }
    }
}