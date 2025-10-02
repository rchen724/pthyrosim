import SwiftUI
import Charts

struct Run3GraphView: View {
    private enum HormoneType: String, CaseIterable {
        case total = "Total"
        case free = "Free"
    }
    
    let run3Result: ThyroidSimulationResult
    let simulationDurationDays: Int
    @EnvironmentObject var simulationData: SimulationData

    @State private var selectedHormoneType: HormoneType = .free
    @State private var showNormalRange: Bool = true
    @State private var showPreviousRuns: Bool = true
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false

    // --- CORRECTED VIEW FOR PDF EXPORT ---
    private var viewToRender: some View {
        VStack(spacing: 20) {
            Text("Run 3 Dosing Simulation Results")
                .font(.title2).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

            GraphSection(
                title: selectedHormoneType == .free ? "Free T4" : "T4",
                yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                xLabel: "Days",
                values: t4GraphData_Run3,
                color: .blue,
                secondaryValues: showPreviousRuns ? run1T4GraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: showPreviousRuns ? run2T4GraphData : nil,
                tertiaryColor: .purple.opacity(0.8),
                yAxisRange: calculateYAxisDomain(for: t4GraphData_Run3.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: selectedHormoneType == .free ? "Free T3" : "T3",
                yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                xLabel: "Days",
                values: t3GraphData_Run3,
                color: .blue,
                secondaryValues: showPreviousRuns ? run1T3GraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: showPreviousRuns ? run2T3GraphData : nil,
                tertiaryColor: .purple.opacity(0.8),
                yAxisRange: calculateYAxisDomain(for: t3GraphData_Run3.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: tshGraphData_Run3,
                color: .blue,
                secondaryValues: showPreviousRuns ? run1TshGraphData : nil,
                secondaryColor: .red.opacity(0.8),
                tertiaryValues: showPreviousRuns ? run2TshGraphData : nil,
                tertiaryColor: .purple.opacity(0.8),
                yAxisRange: calculateYAxisDomain(for: tshGraphData_Run3.map { $0.1 }, title: "TSH"),
                xAxisRange: effectiveXAxisRange,
                showNormalRange: $showNormalRange
            )
        }
        .padding()
        .background(Color.white)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Run 3 Dosing Simulation Results")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    VStack(spacing: 15) {
                        Picker("Hormone Type", selection: $selectedHormoneType) {
                            ForEach(HormoneType.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        VStack(spacing: 8) {
                            Text("Normal ranges shown in yellow")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Toggle("Show Previous Runs", isOn: $showPreviousRuns)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Legend for Run 3 graphs (in chronological order)
                            if showPreviousRuns {
                                HStack(spacing: 15) {
                                    HStack(spacing: 6) {
                                        Rectangle()
                                            .fill(Color.red.opacity(0.8))
                                            .frame(width: 20, height: 3)
                                        Text("Run 1")
                                            .font(.caption)
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Rectangle()
                                            .fill(Color.purple.opacity(0.8))
                                            .frame(width: 20, height: 3)
                                        Text("Run 2")
                                            .font(.caption)
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: 20, height: 3)
                                        Text("Run 3")
                                            .font(.caption)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        //Toggle("Show Normal Range", isOn: $showNormalRange)
                    }
                
                let effectiveXAxisRange: ClosedRange<Double> = 0...Double(max(1, simulationDurationDays))

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T4" : "T4",
                    yLabel: selectedHormoneType == .free ? "FT4 (ng/dL)" : "T4 (µg/L)",
                    xLabel: "Days",
                    values: t4GraphData_Run3,
                    color: .blue,
                    secondaryValues: showPreviousRuns ? run1T4GraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: showPreviousRuns ? run2T4GraphData : nil,
                    tertiaryColor: .purple,
                    yAxisRange: calculateYAxisDomain(for: t4GraphData_Run3.map { $0.1 }, title: selectedHormoneType == .free ? "Free T4" : "T4"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: selectedHormoneType == .free ? "Free T3" : "T3",
                    yLabel: selectedHormoneType == .free ? "FT3 (pg/mL)" : "T3 (ng/dL)",
                    xLabel: "Days",
                    values: t3GraphData_Run3,
                    color: .blue,
                    secondaryValues: showPreviousRuns ? run1T3GraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: showPreviousRuns ? run2T3GraphData : nil,
                    tertiaryColor: .purple,
                    yAxisRange: calculateYAxisDomain(for: t3GraphData_Run3.map { $0.1 }, title: selectedHormoneType == .free ? "Free T3" : "T3"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )

                GraphSection(
                    title: "TSH",
                    yLabel: "TSH (mU/L)",
                    xLabel: "Days",
                    values: tshGraphData_Run3,
                    color: .blue,
                    secondaryValues: showPreviousRuns ? run1TshGraphData : nil,
                    secondaryColor: .red,
                    tertiaryValues: showPreviousRuns ? run2TshGraphData : nil,
                    tertiaryColor: .purple,
                    yAxisRange: calculateYAxisDomain(for: tshGraphData_Run3.map { $0.1 }, title: "TSH"),
                    xAxisRange: effectiveXAxisRange,
                    showNormalRange: $showNormalRange
                )
            }
            .padding()
        }
        .navigationTitle("Run 3 Dosing Simulation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // --- CORRECTED BUTTON ACTION ---
                    // Use a Task to run the async PDF rendering
                    Task {
                        // 'await' waits for the function to finish and return the URL
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
                    if let pdfURL {
                        ShareSheet(activityItems: [pdfURL])
                    }
                }
    }
    
    // Helper functions for current run data
    private var t4GraphData_Run3: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? run3Result.ft4 : run3Result.t4
        return zip(run3Result.time, sourceData).filter { $0.1.isFinite }
    }
    private var t3GraphData_Run3: [(Double, Double)] {
        let sourceData = selectedHormoneType == .free ? run3Result.ft3 : run3Result.t3
        return zip(run3Result.time, sourceData).filter { $0.1.isFinite }
    }
    private var tshGraphData_Run3: [(Double, Double)] {
        return zip(run3Result.time, run3Result.tsh).filter { $0.1.isFinite }
    }
    
    // Helper functions for Run 1 data (green line)
    private var run1T4GraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run1Result = simulationData.run1Result {
            let sourceData = selectedHormoneType == .free ? run1Result.ft4 : run1Result.t4
            return zip(run1Result.time, sourceData).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    private var run1T3GraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run1Result = simulationData.run1Result {
            let sourceData = selectedHormoneType == .free ? run1Result.ft3 : run1Result.t3
            return zip(run1Result.time, sourceData).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    private var run1TshGraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run1Result = simulationData.run1Result {
            return zip(run1Result.time, run1Result.tsh).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    // Helper functions for Run 2 data (orange line)
    private var run2T4GraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run2Result = simulationData.run2Result {
            let sourceData = selectedHormoneType == .free ? run2Result.ft4 : run2Result.t4
            return zip(run2Result.time, sourceData).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    private var run2T3GraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run2Result = simulationData.run2Result {
            let sourceData = selectedHormoneType == .free ? run2Result.ft3 : run2Result.t3
            return zip(run2Result.time, sourceData).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    private var run2TshGraphData: [(Double, Double)]? {
        guard showPreviousRuns else { return nil }
        
        if let run2Result = simulationData.run2Result {
            return zip(run2Result.time, run2Result.tsh).filter { $0.1.isFinite }
        }
        
        return nil
    }
    
    // Helper function to get all previous runs for consistent Y-axis calculation
    private func getAllPreviousRuns() -> [ThyroidSimulationResult] {
        var allRuns: [ThyroidSimulationResult] = []
        
        // Add Run 1 if available
        if let run1Result = simulationData.run1Result {
            allRuns.append(run1Result)
        }
        
        // Add Run 2 if available
        if let run2Result = simulationData.run2Result {
            allRuns.append(run2Result)
        }
        
        return allRuns
    }
    
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
        // Get all values from current run and all previous runs for consistent Y-axis
        var allValues = values
        
        // Add values from all previous runs
        let allPreviousRuns = getAllPreviousRuns()
        for run in allPreviousRuns {
            let sourceData: [Double]
            switch title {
            case "T4":
                sourceData = run.t4
            case "Free T4":
                sourceData = run.ft4
            case "T3":
                sourceData = run.t3
            case "Free T3":
                sourceData = run.ft3
            case "TSH":
                sourceData = run.tsh
            default:
                sourceData = []
            }
            allValues.append(contentsOf: sourceData.filter { $0.isFinite })
        }
        
        let dataRange = dynamicRange(for: allValues)
        var upperBound: Double
        if showNormalRange, let normalRange = getNormalRange(for: title) {
            upperBound = max(dataRange.upperBound, normalRange.upperBound)
        } else {
            upperBound = dataRange.upperBound
        }
        let padding = abs(upperBound) * 0.05
        return 0...(upperBound + padding)
    }
}

