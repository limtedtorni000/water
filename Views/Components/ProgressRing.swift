import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat = 18
    let size: CGFloat = 160
    let showGradient: Bool = true
    
    var body: some View {
        ZStack {
            // Background circle with subtle gradient
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.1), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
            
            // Progress circle with gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    showGradient ? AnyShapeStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) : AnyShapeStyle(color),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: progress)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .frame(width: size, height: size)
    }
}

struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ProgressRing(progress: 0.75, color: .waterBlue)
            ProgressRing(progress: 0.5, color: .caffeineBrown)
        }
        .padding()
    }
}