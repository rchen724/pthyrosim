//
//  page3.swift
//  biocyberneticsapp
//
//  Created by Shruthi Sathya on 4/15/25.
//

import SwiftUI

struct Step2View: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: [.top, .horizontal]) // Respect bottom safe area

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Do Simulated Dosing Experiment")
                        .font(.title2.bold())

                    Text("How: T3 and/or T4 input dosing can be chosen as oral doses; OR intravenous (IV) bolus doses; OR infusion doses.")
                        .font(.body)
                        .foregroundColor(.gray)

                    HStack(alignment: .top, spacing: 40) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("T3 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                VStack {
                                    Image("pill1")
                                    Text("oral dose")
                                }
                                VStack {
                                    Image("syringe1")
                                    Text("IV bolus dose")
                                }
                                VStack {
                                    Image("infusion1")
                                    Text("infusion dose")
                                }
                            }
                        }

                        VStack(alignment: .center, spacing: 16) {
                            Text("T4 Input:")
                                .font(.headline)
                            VStack(spacing: 12) {
                                VStack {
                                    Image("pill2")
                                    Text("oral dose")
                                }
                                VStack {
                                    Image("syringe2")
                                    Text("IV bolus dose")
                                }
                                VStack {
                                    Image("infusion2")
                                    Text("infusion dose")
                                }
                            }
                        }
                    }

                    Text("What: Combinations of T3 and T4 can be added as dosage inputs at different times and types.")
                        .font(.body)
                        .foregroundColor(.gray)

                    // Instruction box
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW TO CONDUCT DOSING EXPERIMENT?")
                            .font(.headline)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Click on an icon to add as input")
                            Text("• Click one or more icons to add as many inputs and/or at as many times as desired")
                            Text("• Euthyroid - Normal hormone responses are simulated, shown can be plotted and saved in Step 3 and results can be plotted and saved")
                        }
                        .font(.footnote)
                    }
                    .padding()

                    Spacer().frame(height: 80) // Leave space for navigation bar
                }
                .padding()
                .foregroundColor(.white)
            }
        }
    }
}

struct Step2View_Previews: PreviewProvider {
    static var previews: some View {
        Step2View()
    }
}
