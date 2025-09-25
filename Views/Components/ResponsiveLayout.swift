import SwiftUI

struct ResponsiveLayout {
    static var isiPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    static var horizontalPadding: CGFloat {
        isiPad ? 60 : 16
    }
    
    static var verticalPadding: CGFloat {
        isiPad ? 24 : 16
    }
    
    static var itemSpacing: CGFloat {
        isiPad ? 24 : 16
    }
    
    static var maxContentWidth: CGFloat? {
        isiPad ? nil : nil
    }
    
    static var gridColumns: [GridItem] {
        let count = isiPad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: itemSpacing), count: count)
    }
    
    static var cardCornerRadius: CGFloat {
        isiPad ? 20 : 16
    }
}