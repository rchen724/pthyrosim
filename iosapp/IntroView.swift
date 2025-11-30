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
    @State private var showDisclaimer = false
    @State private var showDescription = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Title and subtitle
                VStack(spacing: 2) {
                    Text("p-THYROSIM")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 5) {
                        Text("iOS Version 1.0")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Button(action: { showDisclaimer = true }) {
                            Image(systemName: "info.circle")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 20)

                // Image
                Image("thyrosim")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 225)
                    .padding(.horizontal, 5)
                Button(action: { showDescription = true }) {
                    Text("Read About p-THYROSIM  FIRST!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        Text("References")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("1.")
                                Text("Cruz Loya et al. doi: 10.3389/fendo.2022.888429")
                            }
                            HStack(alignment: .top) {
                                Text("2.")
                                Text("JJ DiStefano III et al. Personalized p-THYROSIM model...")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 5) {
                        Text("People & Acknowledgements")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top) {
                                Text("Director:")
                                    .bold()
                                    .frame(width: 120, alignment: .leading)
                                Text("JJ DiStefano III")
                            }
                            
                            HStack(alignment: .top) {
                                Text("App Developers:")
                                    .bold()
                                    .frame(width: 120, alignment: .leading)
                                Text("Rita Chen, Shruthi S Narayanan, Ashwin Joshi")
                            }
                            
                            HStack(alignment: .top) {
                                Text("Modeling:")
                                    .bold()
                                    .frame(width: 120, alignment: .leading)
                                Text("Ben Chu, Mauricio Cruz Loya, Karim Ghabra, Katarina Reid, Distefano Lab team")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    }

                    Text("© December 2025 by UCLA Biocybernetics Laboratory")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showDescription) {
            DescriptionPopupView()
        }
        .alert("Disclaimer", isPresented: $showDisclaimer) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("p-THYROSIM is intended as an educational and research tool only. Information provided is not a substitute for medical advice. Please contact your doctor regarding any medical conditions or questions you have.")
        }
    }
}

struct DescriptionPopupView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VStack {
                ScrollView {
                    Text("p-THYROSIM is a personalized tool for simulating and visualizing the dynamics of human thyroid hormone (TH) regulation under normal and hypothyroid conditions. It was developed and well-validated from real normal and hypothyroid human data*. It accepts an individual's hormone, gender, weight and height data, as well as hormone dosing options, and provides graphs of their simulated hormone dynamic responses, for euthyroid and hypothyroid conditions, over periods up to 100 days. Users simulate common thyroid system maladies by adjusting TH secretion and/or absorption rates and simulation intervals on the interface (in Step 1). For patients receiving replacement hormones, Step 2 provides several and/or multiple oral input dosing options. Intravenous bolus and/or infusion inputs can also be chosen, for exploratory research and teaching demonstrations. For easy comparisons, the interface includes facility for superimposing up to 3 sets of simulation results (Step3). \n\n**Importantly, p-THYROSIM is not for self-medication, and not a substitute for professional medical advice.**\n\nBy offering a user-friendly interface, it enables users to gain insights into complex thyroid hormone interactions with remarkable precision. Whether for academic learning or clinical teaching, the tool serves as a gateway to unraveling the intricacies of thyroid physiology. Furthermore, its ability to simulate personalized responses to varied conditions makes it a valuable tool for advancing both education and exploratory research as well as clinical applications.")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 40, leading: 20, bottom: 20, trailing: 20))
                }
            }

            // Close button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
