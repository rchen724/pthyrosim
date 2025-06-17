//
//  PrintableSimulationGraphView.swift
//  iosapp
//
//  Created by Rita Chen on 6/16/25.
//

import SwiftUI


struct PrintableSimulationGraphView: View {
    var result: ThyroidSimulationResult
    var simulationDurationDays: Int
    
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        let effectiveXAxisRange: ClosedRange<Double> = {
            if result.time.isEmpty {
                let upper = Double(simulationDurationDays)
                return 0.0...(upper > 0.0 ? upper : 0.1)
            } else {
                let first = result.time.first ?? 0.0
                let last = max(result.time.last ?? 0.0, Double(simulationDurationDays))
                return first < last ? first...last : (last - 0.1)...last
            }
        }()

        VStack(spacing: 20){
            GraphSection(
                title: "T4",
                yLabel: "T4 (µg/L)",
                xLabel: "Days",
                values: result.time.indices.map { (result.time[$0], result.t4[$0]) },
                color: .blue,
                yAxisRange: dynamicRange(result.t4),
                xAxisRange: effectiveXAxisRange
            )

            GraphSection(
                title: "T3",
                yLabel: "T3 (µg/L)",
                xLabel: "Days",
                values: result.time.indices.map { (result.time[$0], result.t3[$0]) },
                color: .green,
                yAxisRange: dynamicRange(result.t3),
                xAxisRange: effectiveXAxisRange
            )

            GraphSection(
                title: "TSH",
                yLabel: "TSH (mU/L)",
                xLabel: "Days",
                values: result.time.indices.map { (result.time[$0], result.tsh[$0]) },
                color: .red,
                yAxisRange: dynamicRange(result.tsh),
                xAxisRange: effectiveXAxisRange
            )
        }
        .padding()
        .background(GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            contentHeight = geo.size.height
                        }
                })
                .fixedSize(horizontal: false, vertical: true)
    }
}
