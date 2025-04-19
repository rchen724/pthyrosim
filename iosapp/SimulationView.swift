//
//  Page4View.swift
//  biocyberneticsapp
//
//  Created by Shruthi Sathya on 4/15/25.
//

import SwiftUI

struct SimulationView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(edges: [.top, .horizontal]) // Keep bottom safe area for nav bar
            
            VStack(spacing: 30) {
                Text("Run Simulation")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top)

                // Image placeholder
                Image("thyrosim")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 350)
                    .padding(.horizontal)

                // Simulation Button
                Button(action: {
                    // Action when button is tapped
                    print("Simulation Started")
                }) {
                    Text("START SIMULATION")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                }

                Spacer() // Pushes content up and makes space for bottom nav
                    .frame(height: 80) // Adjust height as needed
            }
        }
    }
}

struct SimulationView_Previews: PreviewProvider {
    static var previews: some View {
        SimulationView()
    }
}
