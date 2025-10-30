import SwiftUI
import Charts

struct Run2GraphView: View {
    private enum HormoneType: String, CaseIterable {
        case free = "Free"
        case total = "Total"
    }

    let run2Result: ThyroidSimulationResult
    let simulationDurationDays: Int
    @EnvironmentObject var simulationData: SimulationData

    @State private var selectedHormoneType: HormoneType = .free
    @State private var showNormalRange: Bool = true
    @State private var showPreviousRun1: Bool = true

    // ----- PDF Export -----
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

    private var viewToRender: some View {
        VStack(spacing: 5) {
            Text("Run 2 Dosing Simulation Results")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

            GraphSection(
                title: selectedHormoneType == .free ? "Free T4" : "T4",
                yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                xLabel: "Days",
                values: t4GraphData_Run2,
                color: .blue,
                secondaryValues: showPreviousRun1 ? run1T4GraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: nil,
                tertiaryColor: nil,
                yAxisRange: calculateYAxisDomain(for: t4GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: selectedHormoneType == .free ? "Free T3" : "T3",
                yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                xLabel: "Days",
                values: t3GraphData_Run2,
                color: .blue,
                secondaryValues: showPreviousRun1 ? run1T3GraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: nil,
                tertiaryColor: nil,
                yAxisRange: calculateYAxisDomain(for: t3GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: tshGraphData_Run2,
                color: .blue,
                secondaryValues: showPreviousRun1 ? run1TshGraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: nil,
                tertiaryColor: nil,
                yAxisRange: calculateYAxisDomain(for: tshGraphData_Run2.map { $0.1 }, title: "TSH"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )
        }
        .padding()
        .background(Color.white)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 5) {

                // Controls / legend
                VStack(spacing: 6) {
                    Picker("Hormone Type", selection: $selectedHormoneType) {
                        ForEach(HormoneType.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)

                    Text("Normal ranges shown in yellow")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Toggle("Show Run 1 (previous) overlay", isOn: $showPreviousRun1)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if showPreviousRun1 {
                        HStack(spacing: 15) {
                            HStack(spacing: 6) {
                                Rectangle().fill(Color.red.opacity(0.85))
                                    .frame(width: 20, height: 3)
                                Text("Run 1")
                                    .font(.caption)
                            }
                            HStack(spacing: 6) {
                                Rectangle().fill(Color.blue)
                                    .frame(width: 20, height: 3)
                                Text("Run 2")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))
                let h: CGFloat = 160

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T4" : "T4",
                    yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: t4GraphData_Run2,
                    color: .blue,
                    secondaryValues: showPreviousRun1 ? run1T4GraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: nil,
                    tertiaryColor: nil,
                    yAxisRange: calculateYAxisDomain(for: t4GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange,
                    chartHeight: h
                )

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T3" : "T3",
                    yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                    xLabel: "Days",
                    values: t3GraphData_Run2,
                    color: .blue,
                    secondaryValues: showPreviousRun1 ? run1T3GraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: nil,
                    tertiaryColor: nil,
                    yAxisRange: calculateYAxisDomain(for: t3GraphData_Run2.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange,
                    chartHeight: h
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: tshGraphData_Run2,
                    color: .blue,
                    secondaryValues: showPreviousRun1 ? run1TshGraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: nil,
                    tertiaryColor: nil,
                    yAxisRange: calculateYAxisDomain(for: tshGraphData_Run2.map { $0.1 }, title: "TSH"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange,
                    chartHeight: h
                )
            }
            .padding()
        }
        .navigationTitle("Run 2 Dosing Simulation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        let url = await renderViewToPDF(view: viewToRender)
                        self.pdfURL = url
                        self.showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL { ShareSheet(activityItems: [pdfURL]) }
        }
    }

    // MARK: - Current Run 2 data
    private var t4GraphData_Run2: [(Double, Double)] {
        let src = (selectedHormoneType == .free) ? run2Result.ft4 : run2Result.t4
        return zip(run2Result.time, src).filter { $0.1.isFinite }
    }
    private var t3GraphData_Run2: [(Double, Double)] {
        let src = (selectedHormoneType == .free) ? run2Result.ft3 : run2Result.t3
        return zip(run2Result.time, src).filter { $0.1.isFinite }
    }
    private var tshGraphData_Run2: [(Double, Double)] {
        zip(run2Result.time, run2Result.tsh).filter { $0.1.isFinite }
    }

    // MARK: - Run 1 overlay (previous)
    private var run1T4GraphData: [(Double, Double)]? {
        guard showPreviousRun1, let r1 = simulationData.run1Result else { return nil }
        let src = (selectedHormoneType == .free) ? r1.ft4 : r1.t4
        return zip(r1.time, src).filter { $0.1.isFinite }
    }
    private var run1T3GraphData: [(Double, Double)]? {
        guard showPreviousRun1, let r1 = simulationData.run1Result else { return nil }
        let src = (selectedHormoneType == .free) ? r1.ft3 : r1.t3
        return zip(r1.time, src).filter { $0.1.isFinite }
    }
    private var run1TshGraphData: [(Double, Double)]? {
        guard showPreviousRun1, let r1 = simulationData.run1Result else { return nil }
        return zip(r1.time, r1.tsh).filter { $0.1.isFinite }
    }

    // MARK: - Axis helpers (match your Run3 logic)
    private func getNormalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4": return 50.0...120.0
        case "Free T4": return 8...18
        case "T3": return 0.8...1.8
        case "Free T3": return 2.3...4.2
        case "TSH": return 0.4...4.5
        default: return nil
        }
    }
    private func dynamicRange(for values: [Double]) -> ClosedRange<Double> {
        guard let minVal = values.min(), let maxVal = values.max() else { return 0...1 }
        if minVal == maxVal {
            let buffer = abs(minVal * 0.1) > 0 ? abs(minVal * 0.1) : 1.0
            return (minVal - buffer)...(maxVal + buffer)
        }
        let buffer = (maxVal - minVal) * 0.1
        return (minVal - buffer)...(maxVal + buffer)
    }
    private func calculateYAxisDomain(for values: [Double], title: String) -> ClosedRange<Double> {
        var allValues = values
        if let r1 = simulationData.run1Result {
            let src: [Double]
            switch title {
            case "T4": src = r1.t4
            case "Free T4": src = r1.ft4
            case "T3": src = r1.t3
            case "Free T3": src = r1.ft3
            case "TSH": src = r1.tsh
            default: src = []
            }
            allValues.append(contentsOf: src.filter { $0.isFinite })
        }
        let dataRange = dynamicRange(for: allValues)
        let upperBound: Double = {
            if showNormalRange, let nr = getNormalRange(for: title) {
                return max(dataRange.upperBound, nr.upperBound)
            }
            return dataRange.upperBound
        }()
        let padding = abs(upperBound) * 0.05
        return 0...(upperBound + padding)
    }
}
