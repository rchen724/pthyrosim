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
    @State private var initialScrollOffset: CGFloat? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1
    @State private var showDisclaimer = false
    
    // Separate state for description scrollbar
    @State private var descriptionScrollOffset: CGFloat = 0
    @State private var descriptionContentHeight: CGFloat = 1
    @State private var descriptionScrollViewHeight: CGFloat = 1

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 2) {
                        // Track scroll offset using GeometryReader for main page
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                self.scrollOffset = -geo.frame(in: .named("mainScroll")).origin.y
                            }
                            return Color.clear
                        }
                        .frame(height: 0) // invisible spacer to track scroll position

                        // Title and subtitle
                        VStack(spacing: 2) {
                            Text("p-THYROSIM")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Text("iOS Version 1.0 *")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    showDisclaimer = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top)

                        // Main description text with its own scrollable area
                        VStack(spacing: 8) {
                            
                            ZStack(alignment: .topTrailing) {
                                ScrollView(showsIndicators: false) {
                                    Text("p-THYROSIM is a personalized tool for simulating and visualizing the dynamics of human thyroid hormone (TH) regulation under normal and hypothyroid conditions. It was developed and well-validated from real normal and hypothyroid human data*. It accepts an individual's hormone, gender, weight and height data, as well as hormone dosing options, and provides graphs of their simulated hormone dynamic responses, for euthyroid and hypothyroid conditions, over periods up to 100 days. Users simulate common thyroid system maladies by adjusting TH secretion and/or absorption rates and simulation intervals)on the interface (in Step 1). For patients receiving replacement hormones, Step 2 provides several and/or multiple oral input dosing options. Intravenous bolus and/or infusion inputs can also be chosen, for exploratory research and teaching demonstrations. For easy comparisons, the interface includes facility for superimposing up to 3 sets of simulation results (Step3). Importantly, p-THYROSIM is not for self-medication, and not a substitute for professional medical advice. By offering a user-friendly interface, it enables users to gain insights into complex thyroid hormone interactions with remarkable precision. Whether for academic learning or clinical teaching, the tool serves as a gateway to unraveling the intricacies of thyroid physiology. Furthermore, its ability to simulate personalized responses to varied conditions makes it invaluable for advancing both education and exploratory research as well as clinical applications.")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .background(
                                            GeometryReader { geo -> Color in
                                                DispatchQueue.main.async {
                                                    self.descriptionContentHeight = geo.size.height
                                                }
                                                return Color.clear
                                            }
                                        )
                                        .background(
                                            GeometryReader { geo in
                                                Color.clear
                                                    .preference(key: ScrollOffsetKey.self,
                                                                value: -geo.frame(in: .named("descriptionScroll")).origin.y)
                                            }
                                        )
                                }
                                .coordinateSpace(name: "descriptionScroll")
                                .frame(height: 200) // Fixed height for the description area
                                .background(
                                    GeometryReader { geo -> Color in
                                        DispatchQueue.main.async {
                                            self.descriptionScrollViewHeight = geo.size.height
                                        }
                                        return Color.clear
                                    }
                                )
                                .onPreferenceChange(ScrollOffsetKey.self) { value in
                                    self.descriptionScrollOffset = max(0, value)
                                }
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)

                                // Custom scrollbar for description
                                if descriptionContentHeight > descriptionScrollViewHeight {
                                    let maxScroll = max(descriptionContentHeight - descriptionScrollViewHeight, 0)
                                    let clampedScrollOffset = min(max(descriptionScrollOffset, 0), maxScroll)
                                    let scrollProgress = maxScroll > 0 ? (clampedScrollOffset / maxScroll) : 0
                                    let visibleRatio = descriptionScrollViewHeight / descriptionContentHeight
                                    let thumbHeight = max(descriptionScrollViewHeight * visibleRatio, 20)
                                    let thumbTop = scrollProgress * (descriptionScrollViewHeight - thumbHeight)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.6))
                                        .frame(width: 4, height: thumbHeight)
                                        .padding(.trailing, 2)
                                        .offset(y: thumbTop)
                                        .animation(.easeInOut(duration: 0.15), value: thumbTop)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Bigger image section
                        VStack(spacing: 16) {
                            Image("thyrosim")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300) // Made much bigger
                                .padding(.horizontal)
                        }

                        Text("*Cruz Loya et al. doi: 10.3389/fendo.2022.888429")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Acknowledgements
                        VStack(spacing: 4) {
                            Text("People & Acknowledgements:")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("1. JJ DiStefano III - Director")
                                Text("2. App Developers: Rita Chen, Shruthi S Narayanan")
                                Text("3. Modelling and analysis by: Ben Chu, Mauricio Cruz Loya, Karim Ghabra, Katarina Reid, Distefano Lab team")
                            }
                            .font(.footnote)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            
                            // Copyright below acknowledgements
                            Text("© October 2025 by UCLA Biocybernetics Lab")
                                .font(.callout)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30) // Extra padding at bottom for tab bar
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                self.contentHeight = geo.size.height
                            }
                            return Color.clear
                        }
                    )
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .coordinateSpace(name: "mainScroll")
                .background(Color.black.ignoresSafeArea())
            }
            .navigationTitle("Intro")
            .navigationBarHidden(true)
        }
        .alert("Disclaimer", isPresented: $showDisclaimer) {
            Button("OK") { }
        } message: {
            Text("Thyrosim is intended as an educational and research tool only. Information provided is not a substitute for medical advice and you should contact your doctor regarding any medical conditions or medical questions you have.")
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
