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
                Text("p-THYROSIM")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Image placeholder
                
                // Simulation Button
                VStack(alignment: .center, spacing: 24) {
                    ScrollView{
                        Text("p-THYROSIM is a personalized tool for simulating and visualizing the dynamics of human thyroid hormone (TH) regulation under normal and hypothyroid conditions. It was developed and well-validated from real normal and hypothyroid human data*. It accepts an individual’s hormone, gender, weight and height data, as well as hormone dosing options, and provides graphs of their simulated hormone dynamic responses, for euthyroid and hypothyroid conditions, over periods up to 100 days. Users simulate common thyroid system maladies by adjusting TH secretion and/or absorption rates and simulation intervals)on the interface (in Step 1). For patients receiving replacement hormones, Step 2 provides several and/or multiple oral input dosing options. Intravenous bolus and/or infusion inputs can also be chosen, for exploratory research and teaching demonstrations. For easy comparisons, the interface includes facility for superimposing 2 sets of simulation results (Step3). Importantly, p-THYROSIM is not for self-medication, and not a substitute for professional medical advice. By offering a user-friendly interface, it enables users to gain insights into complex thyroid hormone interactions with remarkable precision. Whether for academic learning or clinical teaching, the tool serves as a gateway to unraveling the intricacies of thyroid physiology. Furthermore, its ability to simulate personalized responses to varied conditions makes it invaluable for advancing both education and exploratory research as well as clinical applications.")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Image("thyrosim")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .padding(.horizontal)
                    
                    Text("*Cruz Loya et al. doi: 10.3389/fendo.2022.888429")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer() // Pushes content up and makes space for bottom nav
                        .frame(height: 80) // Adjust height as needed
                }
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        SimulationView()
    }
}
