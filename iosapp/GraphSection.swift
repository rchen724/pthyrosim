import SwiftUI
import Charts

struct GraphSection: View {
    let title: String
    let yLabel: String
    let xLabel: String
    
    // Primary data series (Run 1)
    let values: [(Double, Double)]
    let color: Color
    
    // Secondary data series (Run 2)
    let secondaryValues: [(Double, Double)]?
    let secondaryColor: Color?

    let initialYAxisRange: ClosedRange<Double>
    let initialXAxisRange: ClosedRange<Double>

    // State variables for zoom/pan
    @State private var currentXDomain: ClosedRange<Double>
    @State private var currentYDomain: ClosedRange<Double>
    @State private var gestureStartDomainX: ClosedRange<Double>?
    @State private var gestureStartDomainY: ClosedRange<Double>?
    @State private var currentMagnification: CGFloat = 1.0
    @State private var currentTranslation: CGSize = .zero

    private let minDomainSpanFactor: CGFloat = 0.01 // Max zoom in
    private let maxDomainSpanFactor: CGFloat = 20.0  // Max zoom out

    init(title: String, yLabel: String, xLabel: String, values: [(Double, Double)], color: Color, secondaryValues: [(Double, Double)]? = nil, secondaryColor: Color? = nil, yAxisRange: ClosedRange<Double>, xAxisRange: ClosedRange<Double>) {
        self.title = title
        self.yLabel = yLabel
        self.xLabel = xLabel
        self.values = values
        self.color = color
        self.secondaryValues = secondaryValues
        self.secondaryColor = secondaryColor
        
        let validatedXAxisRange = (xAxisRange.lowerBound < xAxisRange.upperBound) ? xAxisRange : (xAxisRange.lowerBound...(xAxisRange.lowerBound + 1.0))
        let validatedYAxisRange = (yAxisRange.lowerBound < yAxisRange.upperBound) ? yAxisRange : (yAxisRange.lowerBound...(yAxisRange.lowerBound + 1.0))

        self.initialXAxisRange = validatedXAxisRange
        self.initialYAxisRange = validatedYAxisRange
        
        // Default zoom to the last 2 days to show oscillations more clearly.
        let maxTimeInDays = validatedXAxisRange.upperBound
        let startTimeInDays = max(validatedXAxisRange.lowerBound, maxTimeInDays - 2)
        let zoomedInXAxisRange = startTimeInDays...maxTimeInDays

        _currentXDomain = State(initialValue: zoomedInXAxisRange.lowerBound < zoomedInXAxisRange.upperBound ? zoomedInXAxisRange : validatedXAxisRange)
        _currentYDomain = State(initialValue: validatedYAxisRange)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                // Legend for the two lines
                if secondaryValues != nil {
                    HStack(spacing: 15) {
                        HStack(spacing: 4) {
                            Rectangle().frame(width: 15, height: 3).foregroundStyle(color)
                            Text("Run 1").font(.caption)
                        }
                        HStack(spacing: 4) {
                            Rectangle().frame(width: 15, height: 3).foregroundStyle(secondaryColor ?? .white)
                            Text("Run 2").font(.caption)
                        }
                    }
                }
                Button { resetZoomAndPan() } label: { Image(systemName: "arrow.uturn.backward.circle").font(.title3) }.buttonStyle(.borderless)
            }
            .padding(.horizontal)


            if values.isEmpty {
                ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis.ascending")
                    .frame(height: 250)
            } else {
                ZStack(alignment: .bottomTrailing) {
                    GeometryReader { chartGeometry in
                        Chart {
                             // Shaded area for the normal range
                             if let range = normalRange(for: title) {
                                 RectangleMark(
                                    xStart: .value("X Start", currentXDomain.lowerBound),
                                    xEnd: .value("X End", currentXDomain.upperBound),
                                    yStart: .value("Normal Min", range.lowerBound),
                                    yEnd: .value("Normal Max", range.upperBound)
                                 )
                                 .foregroundStyle(Color.yellow.opacity(0.2))
                             }

                            // Draw primary line (Run 1)
                            ForEach(Array(values.enumerated()), id: \.offset) { _, point in
                                LineMark(x: .value(xLabel, point.0), y: .value(yLabel, point.1))
                                    .foregroundStyle(color)
                                    .interpolationMethod(.catmullRom)
                            }

                            // Draw secondary line (Run 2), if it exists
                            if let secondary = secondaryValues, let secColor = secondaryColor {
                                ForEach(Array(secondary.enumerated()), id: \.offset) { _, point in
                                    LineMark(x: .value(xLabel, point.0), y: .value(yLabel, point.1))
                                        .foregroundStyle(secColor)
                                        .interpolationMethod(.catmullRom)
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                }
                            }
                        }
                        .chartXScale(domain: currentXDomain)
                        .chartYScale(domain: currentYDomain)
                        .chartPlotStyle { $0.clipped() }
                        .background(Color(UIColor.systemGray6)).cornerRadius(8)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if gestureStartDomainX == nil {
                                        gestureStartDomainX = currentXDomain
                                        gestureStartDomainY = currentYDomain
                                    }
                                    currentTranslation = value.translation
                                    updateDomains(chartRenderSize: chartGeometry.size)
                                }
                                .onEnded { _ in gestureStartDomainX = nil; gestureStartDomainY = nil }
                                .simultaneously(with: MagnificationGesture()
                                    .onChanged { value in
                                        if gestureStartDomainX == nil {
                                            gestureStartDomainX = currentXDomain
                                            gestureStartDomainY = currentYDomain
                                        }
                                        currentMagnification = value
                                        updateDomains(chartRenderSize: chartGeometry.size)
                                    }
                                    .onEnded { _ in gestureStartDomainX = nil; gestureStartDomainY = nil }
                                )
                        )
                    }
                    .frame(height: 250).padding(.horizontal)
                    
                    HStack {
                        Button { zoom(by: 1.25) } label: { Image(systemName: "minus.magnifyingglass") }
                        Button { zoom(by: 0.8) } label: { Image(systemName: "plus.magnifyingglass") }
                    }
                    .font(.title2)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding([.trailing, .bottom], 10)
                    .buttonStyle(.borderless)
                }
            }
        }
        .onChange(of: values.count) {
            resetZoomAndPan()
        }
    }
    
    // MARK: - Helper Functions
    
    private func zoom(by scaleFactor: CGFloat) {
        let newXSpan = currentXDomain.span * scaleFactor
        let newYSpan = currentYDomain.span * scaleFactor
        
        currentXDomain = currentXDomain.zoomed(by: newXSpan)
        currentYDomain = currentYDomain.zoomed(by: newYSpan)
    }
    
    private func updateDomains(chartRenderSize: CGSize) {
        guard let xStart = gestureStartDomainX, let yStart = gestureStartDomainY else { return }
        
        // --- Panning ---
        let xTranslation = currentTranslation.width * (xStart.span / chartRenderSize.width)
        let yTranslation = -currentTranslation.height * (yStart.span / chartRenderSize.height)
        
        let newXLower = xStart.lowerBound - xTranslation
        let newYLower = yStart.lowerBound - yTranslation
        
        // --- Zooming ---
        let newXSpan = xStart.span / currentMagnification
        let newYSpan = yStart.span / currentMagnification
        
        currentXDomain = newXLower...(newXLower + newXSpan)
        currentYDomain = newYLower...(newYLower + newYSpan)
    }

    private func resetZoomAndPan() {
        let maxTimeInDays = initialXAxisRange.upperBound
        let startTimeInDays = max(initialXAxisRange.lowerBound, maxTimeInDays - 2)
        currentXDomain = startTimeInDays...maxTimeInDays
        currentYDomain = initialYAxisRange
    }
    
    /// Returns the normal physiological range for a given hormone.
    func normalRange(for hormone: String) -> ClosedRange<Double>? {
        switch hormone {
        case "T4":
            // From common clinical values, supported by graph visuals in the paper.
            return 50.0...120.0
        case "Free T4":
            // Using common clinical reference ranges for FT4 in µg/L.
            return 10.0...25.0
        case "T3":
            // Based on graph visuals in the paper.
            return 0.8...1.8
        case "Free T3":
            // Using common clinical reference ranges for FT3 in µg/L.
            return 2.3...4.2
        case "TSH":
            // Based on the paper stating the normal range is approximately 0.4 to 4.5 mU/L.
            return 0.4...4.5
        default:
            return nil
        }
    }
}

// MARK: - Helper Extensions

extension ClosedRange where Bound: FloatingPoint {
    var span: Bound { upperBound - lowerBound }
    
    func zoomed(by newSpan: Bound) -> Self {
        let center = lowerBound + span / 2
        return (center - newSpan / 2)...(center + newSpan / 2)
    }
}
