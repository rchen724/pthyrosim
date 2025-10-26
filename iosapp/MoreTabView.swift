import SwiftUI

// MARK: - More Tab (with Reset)
struct MoreTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 6) {
                            Text("More Options")
                                .font(.title2).fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Run 3 Dosing and Simulation")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 16)

                        // Menu cards
                        VStack(spacing: 14) {
                            NavigationLink {
                                Run3DosingInputView()
                            } label: {
                                MenuCard(
                                    title: "Add Dosing (Run 3)",
                                    subtitle: "Configure oral, IV, and infusion dosing",
                                    systemImage: "pills.circle.fill",
                                    tint: .blue
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                Run3View(startAt: .simulate)
                            } label: {
                                MenuCard(
                                    title: "Simulate Run 3",
                                    subtitle: "Run the model and view graphs",
                                    systemImage: "chart.line.uptrend.xyaxis",
                                    tint: .purple
                                )
                            }
                            .buttonStyle(.plain)

                            // RESET card
                            ResetAppCardButton()
                                .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 20)
                    }
                }
            }
        }
    }
}

// MARK: - Reset Card Button (uses EnvironmentObject + AppStorage, self-contained)
private struct ResetAppCardButton: View {
    @EnvironmentObject var simulationData: SimulationData
    @State private var showConfirm = false

    // Inputs you want to reset to defaults
    @AppStorage("t4Secretion") private var t4Secretion: String = "100"
    @AppStorage("t3Secretion") private var t3Secretion: String = "100"
    @AppStorage("t4Absorption") private var t4Absorption: String = "88"
    @AppStorage("t3Absorption") private var t3Absorption: String = "88"
    @AppStorage("height") private var height: String = "170"
    @AppStorage("weight") private var weight: String = "70"
    @AppStorage("selectedHeightUnit") private var selectedHeightUnit: String = "cm"
    @AppStorage("selectedWeightUnit") private var selectedWeightUnit: String = "kg"
    @AppStorage("selectedGender") private var selectedGender: String = "FEMALE"
    @AppStorage("simulationDays") private var simulationDays: String = "5"
    @AppStorage("isInitialConditionsOn") private var isInitialConditionsOn: Bool = true

    // Keep Run 1 tab labeling as “Run 1” going forward
    @AppStorage("hasRunRun1Once") private var hasRunRun1Once: Bool = true

    // Navigate back to Input tab (index 1 in your MainView)
    @AppStorage("selectedMainTab") private var selectedMainTab: Int = 0

    var body: some View {
        Button {
            showConfirm = true
        } label: {
            MenuCard(
                title: "Reset All",
                subtitle: "Clear Run 2 & Run 3 doses/results and restore default inputs",
                systemImage: "arrow.counterclockwise",
                tint: .red
            )
        }
        .alert("Reset All Settings?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("This clears all Run 2 & Run 3 dosing/results and restores default inputs. You will be brought back to the input page.")
        }
    }

    private func performReset() {
        // 1) Reset inputs to defaults
        t4Secretion = "100"
        t3Secretion = "100"
        t4Absorption = "88"
        t3Absorption = "88"
        height = "170"
        weight = "70"
        selectedHeightUnit = "cm"
        selectedWeightUnit = "kg"
        selectedGender = "FEMALE"
        simulationDays = "5"
        isInitialConditionsOn = false

        // 2) Preserve that Run 1 has been completed at least once
        hasRunRun1Once = true

        // 3) Clear Run 2 & Run 3 state; keep Run 1
        simulationData.resetForNewPlanPreservingRun1()

        // 4) Take user back to the Input tab
        selectedMainTab = 1
    }
}

// MARK: - SimulationData helper to clear R2/R3 & keep R1
extension SimulationData {
    /// Clears Run 2 & Run 3 dosing and results, but preserves Run 1.
    func resetForNewPlanPreservingRun1() {
        // If you also keep generic arrays (non-run-specific), clear those too
        self.t4oralinputs.removeAll()
        self.t3oralinputs.removeAll()
        self.t4ivinputs.removeAll()
        self.t3ivinputs.removeAll()
        self.t4infusioninputs.removeAll()
        self.t3infusioninputs.removeAll()

        // Run 2 specific
        self.run2T4oralinputs.removeAll()
        self.run2T3oralinputs.removeAll()
        self.run2T4ivinputs.removeAll()
        self.run2T3ivinputs.removeAll()
        self.run2T4infusioninputs.removeAll()
        self.run2T3infusioninputs.removeAll()
        self.previousRun2Results.removeAll()
        self.run2Result = nil

        // Run 3 specific
        self.run3T4oralinputs.removeAll()
        self.run3T3oralinputs.removeAll()
        self.run3T4ivinputs.removeAll()
        self.run3T3ivinputs.removeAll()
        self.run3T4infusioninputs.removeAll()
        self.run3T3infusioninputs.removeAll()
        self.previousRun3Results.removeAll()
        // If you store a current run3Result, also nil it here.
        // self.run3Result = nil
        // Keep run1Result on purpose so user doesn’t need to re-run it.
    }
}

// MARK: - Shared Card UI
private struct MenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(tint.opacity(0.2))
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(tint)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(subtitle)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
        )
    }
}
