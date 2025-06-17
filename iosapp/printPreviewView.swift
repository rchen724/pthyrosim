//
//  printPreviewView.swift
//  iosapp
//
//  Created by Rita Chen on 6/16/25.

import SwiftUI
import Foundation

struct PrintPreviewView: View {
    var result: ThyroidSimulationResult
    var simulationDurationDays: Int
    var onPrint: (@escaping () -> Void) -> Void

    @State private var renderedImage: UIImage? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if let image = renderedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    ProgressView("Rendering...")
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Print Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Print") {
                        let image = SimulationGraphView(result: result, simulationDurationDays: simulationDurationDays)
                            .snapshot()
                        
                        printGraphImage(image) {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                renderedImage = PrintableSimulationGraphView(
                    result: result,
                    simulationDurationDays: simulationDurationDays
                ).snapshot()
            }
        }
        .toolbarRole(.editor)
    }
}
