import SwiftUI

struct SimulationConditionsView: View {
    let t4Secretion: String
    let t3Secretion: String
    let t4Absorption: String
    let t3Absorption: String
    let height: String
    let weight: String
    let heightUnit: String
    let weightUnit: String
    let gender: String
    let simulationDays: String
    let isInitialConditionsOn: Bool
    
    // Dosage information (optional, for Run 1 it's empty)
    var t3OralDoses: [T3OralDose] = []
    var t4OralDoses: [T4OralDose] = []
    var t3IVDoses: [T3IVDose] = []
    var t4IVDoses: [T4IVDose] = []
    var t3InfusionDoses: [T3InfusionDose] = []
    var t4InfusionDoses: [T4InfusionDose] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Simulation Conditions:")
                .font(.headline)
                .padding(.bottom, 2)
            
            Group {
                Text("T4 Secretion: \(t4Secretion)%")
                Text("T3 Secretion: \(t3Secretion)%")
                Text("T4 Absorption: \(t4Absorption)%")
                Text("T3 Absorption: \(t3Absorption)%")
                Text("Height: \(height) \(heightUnit)")
                Text("Weight: \(weight) \(weightUnit)")
                Text("Gender: \(gender)")
                Text("Simulation Days: \(simulationDays)")
                Text("Initial Conditions Recalculated: \(isInitialConditionsOn ? "Yes" : "No")")
            }
            .font(.caption)

            if !(t3OralDoses.isEmpty && t4OralDoses.isEmpty &&
                 t3IVDoses.isEmpty && t4IVDoses.isEmpty &&
                 t3InfusionDoses.isEmpty && t4InfusionDoses.isEmpty) {
                
                Text("Dosage Information:")
                    .font(.headline)
                    .padding(.top, 5)
                
                // Display T3 Oral Doses
                if !t3OralDoses.isEmpty {
                    Text("T3 Oral Doses:")
                        .font(.subheadline)
                    ForEach(t3OralDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }
                
                // Display T4 Oral Doses
                if !t4OralDoses.isEmpty {
                    Text("T4 Oral Doses:")
                        .font(.subheadline)
                    ForEach(t4OralDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }

                // Display T3 IV Doses
                if !t3IVDoses.isEmpty {
                    Text("T3 IV Doses:")
                        .font(.subheadline)
                    ForEach(t3IVDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }
                
                // Display T4 IV Doses
                if !t4IVDoses.isEmpty {
                    Text("T4 IV Doses:")
                        .font(.subheadline)
                    ForEach(t4IVDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }

                // Display T3 Infusion Doses
                if !t3InfusionDoses.isEmpty {
                    Text("T3 Infusion Doses:")
                        .font(.subheadline)
                    ForEach(t3InfusionDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }
                
                // Display T4 Infusion Doses
                if !t4InfusionDoses.isEmpty {
                    Text("T4 Infusion Doses:")
                        .font(.subheadline)
                    ForEach(t4InfusionDoses) { dose in
                        Text("  - \(format(dose: dose))")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    // Helper functions to format dose information
    private func format(dose: T4OralDose) -> String { "Oral T4: \(String(format: "%.1f", dose.T4OralDoseInput))µg" + (dose.T4SingleDose ? " at day \(String(format: "%.1f", dose.T4OralDoseStart))" : " every \(String(format: "%.1f", dose.T4OralDoseInterval)) days") }
    private func format(dose: T4IVDose) -> String { "IV T4: \(String(format: "%.1f", dose.T4IVDoseInput))µg at day \(String(format: "%.1f", dose.T4IVDoseStart))" }
    private func format(dose: T4InfusionDose) -> String { "Infusion T4: \(String(format: "%.1f", dose.T4InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T4InfusionDoseStart)) to \(String(format: "%.1f", dose.T4InfusionDoseEnd))" }
    private func format(dose: T3OralDose) -> String { "Oral T3: \(String(format: "%.1f", dose.T3OralDoseInput))µg" + (dose.T3SingleDose ? " at day \(String(format: "%.1f", dose.T3OralDoseStart))" : " every \(String(format: "%.1f", dose.T3OralDoseInterval)) days") }
    private func format(dose: T3IVDose) -> String { "IV T3: \(String(format: "%.1f", dose.T3IVDoseInput))µg at day \(String(format: "%.1f", dose.T3IVDoseStart))" }
    private func format(dose: T3InfusionDose) -> String { "Infusion T3: \(String(format: "%.1f", dose.T3InfusionDoseInput))µg from day \(String(format: "%.1f", dose.T3InfusionDoseStart)) to \(String(format: "%.1f", dose.T3InfusionDoseEnd))" }
}
