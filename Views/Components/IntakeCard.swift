import SwiftUI

struct IntakeCard: View {
    let type: IntakeType
    let amount: Double
    let unit: String
    let time: String
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(type == .water ? "Water" : "Caffeine")
                    .font(.subheadlineBold)
                    .foregroundColor(type == .water ? .waterBlue : .caffeineBrown)
                
                Text("\(String(format: "%.0f", amount)) \(unit)")
                    .font(.body)
                    .foregroundColor(.textPrimary)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: type == .water ? "drop.fill" : "mug.fill")
                .foregroundColor(type == .water ? .waterBlue : .caffeineBrown)
                .font(.title2)
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

struct IntakeCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            IntakeCard(
                type: .water,
                amount: 250,
                unit: "ml",
                time: "10:30 AM"
            ) {}
            
            IntakeCard(
                type: .caffeine,
                amount: 95,
                unit: "mg",
                time: "2:15 PM"
            ) {}
        }
        .padding()
    }
}