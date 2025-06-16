import SwiftUI
import Charts

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    let values: [(Double, Double)]
    let color: Color
    let initialYAxisRange: ClosedRange<Double>
    let initialXAxisRange: ClosedRange<Double>

    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>

    // Store the domain state at the beginning of a gesture sequence
    @State private var gestureStartDomainX: ClosedRange<Double>?
    @State private var gestureStartDomainY: ClosedRange<Double>?
    
    // Store the current magnification and translation from the ongoing gesture
    @State private var currentMagnification: CGFloat = 1.0
    @State private var currentTranslation: CGSize = .zero

    private let minDomainSpanFactor: CGFloat = 0.01 // Allow zooming in to 1% of original span
    private let maxDomainSpanFactor: CGFloat = 20.0  // Allow zooming out to 20x original span

    init(title: String, yLabel: String, xLabel: String, values: [(Double, Double)], color: Color, yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>) {
        self.title = title
        self.yLabel = yLabel
        self.xLabel = xLabel
        self.values = values
        self.color = color
        
        // Validate initial ranges to prevent issues if lowerBound >= upperBound
        let validatedXAxisRange = (xAxisRange.lowerBound < xAxisRange.upperBound) ? xAxisRange : (xAxisRange.lowerBound...(xAxisRange.lowerBound + max(1.0, (values.last?.0 ?? xAxisRange.lowerBound + 1.0) - xAxisRange.lowerBound)))
        let validatedYAxisRange = (yAxisRange.lowerBound < yAxisRange.upperBound) ? yAxisRange : (yAxisRange.lowerBound...(yAxisRange.lowerBound + 1.0))

        self.initialXAxisRange = validatedXAxisRange
        self.initialYAxisRange = validatedYAxisRange
        
        // --- FIX: Start with a zoomed-in view of the last 3 days to see the circadian rhythm ---
        let maxTimeInDays = validatedXAxisRange.upperBound
        let startTimeInDays = max(validatedXAxisRange.lowerBound, maxTimeInDays - 3)
        let zoomedInXAxisRange = startTimeInDays...maxTimeInDays

        // Use the zoomed-in range for the initial state of the chart, but fall back to the full range if it's invalid
        _currentXDomain = State(initialValue: zoomedInXAxisRange.lowerBound < zoomedInXAxisRange.upperBound ? zoomedInXAxisRange : validatedXAxisRange)
        // --- END FIX ---
        
        _currentYDomain = State(initialValue: validatedYAxisRange)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    resetZoomAndPan()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .font(.title3)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)

            if values.isEmpty {
                Text("No data available for \(title).")
                    .italic()
                    .foregroundColor(.secondary)
                    .frame(height: 250, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            } else {
                GeometryReader { chartGeometry in
                    Chart {
                        // Optional: Normal Range display
                        if let range = normalRange(for: title) {
                             RectangleMark(
                                 xStart: .value("Range Start", currentXDomain.lowerBound),
                                 xEnd: .value("Range End", currentXDomain.upperBound),
                                 yStart: .value("Normal Min", range.lowerBound),
                                 yEnd: .value("Normal Max", range.upperBound)
                             )
                             .foregroundStyle(Color.yellow.opacity(0.15)) // Slightly less opaque
                         }

                        ForEach(values, id: \.0) { time, value in
                            LineMark(
                                x: .value(xLabel, time),
                                y: .value(yLabel, value)
                            )
                            .foregroundStyle(color)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartXScale(domain: currentXDomain)
                    .chartYScale(domain: currentYDomain)
                    .chartPlotStyle { plotArea in
                        plotArea.clipped()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0) // Allow drag to start immediately
                            .onChanged { value in
                                if gestureStartDomainX == nil { // First event in a new gesture sequence
                                    gestureStartDomainX = currentXDomain
                                    gestureStartDomainY = currentYDomain
                                    currentMagnification = 1.0 // Reset magnification for this sequence
                                }
                                currentTranslation = value.translation // Accumulate translation for this gesture
                                updateDomains(chartRenderSize: chartGeometry.size)
                            }
                            .onEnded { value in
                                currentTranslation = value.translation
                                updateDomains(chartRenderSize: chartGeometry.size)
                                // Finalize the domain
                                gestureStartDomainX = nil
                                gestureStartDomainY = nil
                                // currentMagnification and currentTranslation will be reset/ignored at the start of the next gesture
                            }
                            .simultaneously(with: MagnificationGesture()
                                .onChanged { value in
                                    if gestureStartDomainX == nil { // First event
                                        gestureStartDomainX = currentXDomain
                                        gestureStartDomainY = currentYDomain
                                        currentTranslation = .zero // Reset translation for this sequence
                                    }
                                    currentMagnification = value // This is the magnification since gesture start
                                    updateDomains(chartRenderSize: chartGeometry.size)
                                }
                                .onEnded { value in
                                    currentMagnification = value
                                    updateDomains(chartRenderSize: chartGeometry.size)
                                    // Finalize the domain
                                    gestureStartDomainX = nil
                                    gestureStartDomainY = nil
                                }
                            )
                    )
                }
                .frame(height: 250)
                .padding(.horizontal)
            }
        }
        .onChange(of: initialXAxisRange) {
            resetZoomAndPan()
        }
        .onChange(of: initialYAxisRange) {
            resetZoomAndPan()
        }
    }
    
    private func updateDomains(chartRenderSize: CGSize) {
        guard let startX = gestureStartDomainX, let startY = gestureStartDomainY else {
            return
        }

        // --- Apply Zoom (scaling) first ---
        var newXLower = startX.lowerBound
        var newXUpper = startX.upperBound
        var newYLower = startY.lowerBound
        var newYUpper = startY.upperBound

        if currentMagnification != 1.0 {
            let centerX = (startX.lowerBound + startX.upperBound) / 2
            let centerY = (startY.lowerBound + startY.upperBound) / 2

            var newXSpan = (startX.upperBound - startX.lowerBound) / Double(currentMagnification)
            var newYSpan = (startY.upperBound - startY.upperBound) / Double(currentMagnification)

            // Apply span limits
            let initialXSpan = initialXAxisRange.upperBound - initialXAxisRange.lowerBound
            let initialYSpan = initialYAxisRange.upperBound - initialYAxisRange.lowerBound
            newXSpan = max(initialXSpan * minDomainSpanFactor, min(initialXSpan * maxDomainSpanFactor, newXSpan))
            newYSpan = max(initialYSpan * minDomainSpanFactor, min(initialYSpan * maxDomainSpanFactor, newYSpan))
            
            if newXSpan <= 0 { newXSpan = initialXSpan * minDomainSpanFactor } // extra guard
            if newYSpan <= 0 { newYSpan = initialYSpan * minDomainSpanFactor } // extra guard


            newXLower = centerX - newXSpan / 2
            newXUpper = centerX + newXSpan / 2
            newYLower = centerY - newYSpan / 2
            newYUpper = centerY + newYSpan / 2
        }
        
        // --- Apply Pan (translation) to the (potentially) zoomed domain ---
        if currentTranslation != .zero && chartRenderSize.width > 0 && chartRenderSize.height > 0 {
            let currentNewXSpan = newXUpper - newXLower
            let currentNewYSpan = newYUpper - newYLower

            let xDataPerPoint = currentNewXSpan / Double(chartRenderSize.width)
            let yDataPerPoint = currentNewYSpan / Double(chartRenderSize.height)
            
            let xDataShift = Double(currentTranslation.width) * xDataPerPoint
            let yDataShift = Double(currentTranslation.height) * yDataPerPoint

            newXLower -= xDataShift
            newXUpper -= xDataShift
            newYLower += yDataShift
            newYUpper += yDataShift
        }

        // Update the domains
        if newXLower < newXUpper {
            currentXDomain = newXLower...newXUpper
        }
        if newYLower < newYUpper {
            currentYDomain = newYLower...newYUpper
        }
    }

    private func resetZoomAndPan() {
        currentXDomain = initialXAxisRange
        currentYDomain = initialYAxisRange
        gestureStartDomainX = nil
        gestureStartDomainY = nil
        currentMagnification = 1.0
        currentTranslation = .zero
    }
    
    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4", "T4 (µg/L)": return 60.0...90.0
        case "T3", "T3 (µg/L)": return 0.8...1.8
        case "TSH", "TSH (mU/L)": return 0.5...4.0
        case "Free T4", "FT4 (µg/L)": return 9.0...23.0
        case "Free T3", "FT3 (µg/L)": return 2.3...4.2
        default:
            if yLabel.contains("T4") && yLabel.lowercased().contains("free") { return 9.0...23.0 }
            if yLabel.contains("T3") && yLabel.lowercased().contains("free") { return 2.3...4.2 }
            if yLabel.contains("T4") { return 60.0...90.0 }
            if yLabel.contains("T3") { return 0.8...1.8 }
            if yLabel.contains("TSH") { return 0.5...4.0 }
            return nil
        }
    }
}
