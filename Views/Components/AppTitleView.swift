import SwiftUI

struct AppTitleView: View {
    let title: String
    let subtitle: String?
    
    init(title: String = "HydraTrack", subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Image(systemName: "drop.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.waterBlue)
                    .opacity(0.8)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AppTitleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AppTitleView()
            AppTitleView(subtitle: "Daily Water & Caffeine Tracker")
        }
        .padding()
    }
}