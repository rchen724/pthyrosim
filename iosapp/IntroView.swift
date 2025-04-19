////
////  ContentView.swift
////  biocyberneticsapp
////
////  Created by Shruthi Sathya on 4/14/25.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//  Page4View.swift
//  biocyberneticsapp
//
//  Created by Shruthi Sathya on 4/15/25.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(edges: [.top, .horizontal]) // Keep bottom safe area for nav bar
            
            VStack(spacing: 30) {
                Text("THYROSIM")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top)

                // Image placeholder

                // Simulation Button
                ScrollView{
                    Text("Thyrosim is a tool for simulating and visualizing the dynamics of human thyroid hormone (TH) regulation under normal and some abnormal conditions.\nIt was developed and well-validated from real normal and hypothyroid human data. It is designed to promote understanding of the basic physiology of this endrocrine system - by laypersons as well as by clinicians and clinical educators and researchers.\n Users can simulate common thyroid system maladies by adjusting TH secretion/absorption rate (and simulation intervals) on the interface (in Step 1). Oral input dosing regimens are also selectable on the inteface to simulate common hormone treatment options (Step 2). Bolus and intravenous infusion inputs can also be added, for exploratory research and teaching demonstrations. For easy comparisons, the interface includes facility for superimposing 2 sets of simulation results (Step3).\nImportantly, THYROSIM is for patient and student education and research, not for self-medication, and not a substitute for professional medical advice.")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image("thyrosim")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 350)
                    .padding(.horizontal)
                
                Spacer() // Pushes content up and makes space for bottom nav
                    .frame(height: 80) // Adjust height as needed
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        SimulationView()
    }
}
