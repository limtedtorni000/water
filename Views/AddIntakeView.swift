import SwiftUI

struct AddIntakeView: View {
    @ObservedObject var viewModel: IntakeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: IntakeType = .water
    @State private var amount: Double = 250
    @State private var customAmount: String = ""
    
    private let waterAmounts: [Double] = [100, 250, 500, 1000]
    private let caffeineAmounts: [Double] = [50, 95, 150, 200]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                typeSelector
                
                amountSection
                
                Spacer()
                
                PrimaryButton(
                    title: "Add Entry",
                    style: .primary
                ) {
                    addIntake()
                }
            }
            .padding()
            .navigationTitle("Add Intake")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var typeSelector: some View {
        HStack(spacing: 16) {
            Button(action: { selectedType = .water }) {
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.title)
                        .foregroundColor(selectedType == .water ? .waterBlue : .secondary)
                    
                    Text("Water")
                        .font(.subheadlineBold)
                        .foregroundColor(selectedType == .water ? .waterBlue : .textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedType == .water ? AnyShapeStyle(Color.waterLight) : AnyShapeStyle(.regularMaterial))
                .cornerRadius(12)
            }
            
            Button(action: { selectedType = .caffeine }) {
                VStack(spacing: 8) {
                    Image(systemName: "mug.fill")
                        .font(.title)
                        .foregroundColor(selectedType == .caffeine ? .caffeineBrown : .secondary)
                    
                    Text("Caffeine")
                        .font(.subheadlineBold)
                        .foregroundColor(selectedType == .caffeine ? .caffeineBrown : .textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedType == .caffeine ? AnyShapeStyle(Color.caffeineLight) : AnyShapeStyle(.regularMaterial))
                .cornerRadius(12)
            }
        }
    }
    
    private var amountSection: some View {
        VStack(spacing: 16) {
            Text("Amount")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(selectedType == .water ? waterAmounts : caffeineAmounts, id: \.self) { value in
                    Button(action: {
                        amount = value
                        customAmount = ""
                    }) {
                        Text("\(String(format: "%.0f", value)) \(selectedType == .water ? viewModel.waterUnit : viewModel.caffeineUnit)")
                            .font(.subheadline)
                            .foregroundColor(amount == value && customAmount.isEmpty ? .white : .textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(amount == value && customAmount.isEmpty ? AnyShapeStyle(selectedType == .water ? Color.waterBlue : Color.caffeineBrown) : AnyShapeStyle(.regularMaterial))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            HStack(spacing: 12) {
                TextField("Custom amount", text: $customAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: customAmount) { _ in
                        if let value = Double(customAmount) {
                            amount = value
                        }
                    }
                
                Text(selectedType == .water ? viewModel.waterUnit : viewModel.caffeineUnit)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    private func addIntake() {
        let finalAmount = Double(customAmount) ?? amount
        viewModel.addIntake(type: selectedType, amount: finalAmount)
        dismiss()
    }
}

#Preview {
    AddIntakeView(viewModel: IntakeViewModel())
}