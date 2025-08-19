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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(edges: [.top, .horizontal]) // Keep bottom safe area for nav bar

            VStack(spacing: 30) {
                           // --- MODIFICATION START ---
                           // This new VStack groups the title and subtitle together
                           // with a smaller, custom spacing.
                           VStack(spacing: 2) {
                               Text("p-THYROSIM")
                                   .font(.title2)
                                   .fontWeight(.semibold)
                                   .foregroundColor(.white)
                               
                               Text("iOS Version 1.0 *")
                                   .font(.subheadline)
                                   .foregroundColor(.white)
                           }
                           .padding(.top)

                VStack(alignment: .center, spacing: 24) {
                    // ScrollView with custom scrollbar for the big block of text
                    ZStack(alignment: .topTrailing) {
                        ScrollView(showsIndicators: false) {
                            Text("p-THYROSIM is a personalized tool for simulating and visualizing the dynamics of human thyroid hormone (TH) regulation under normal and hypothyroid conditions. It was developed and well-validated from real normal and hypothyroid human data*. It accepts an individual’s hormone, gender, weight and height data, as well as hormone dosing options, and provides graphs of their simulated hormone dynamic responses, for euthyroid and hypothyroid conditions, over periods up to 100 days. Users simulate common thyroid system maladies by adjusting TH secretion and/or absorption rates and simulation intervals)on the interface (in Step 1). For patients receiving replacement hormones, Step 2 provides several and/or multiple oral input dosing options. Intravenous bolus and/or infusion inputs can also be chosen, for exploratory research and teaching demonstrations. For easy comparisons, the interface includes facility for superimposing 2 sets of simulation results (Step3). Importantly, p-THYROSIM is not for self-medication, and not a substitute for professional medical advice. By offering a user-friendly interface, it enables users to gain insights into complex thyroid hormone interactions with remarkable precision. Whether for academic learning or clinical teaching, the tool serves as a gateway to unraveling the intricacies of thyroid physiology. Furthermore, its ability to simulate personalized responses to varied conditions makes it invaluable for advancing both education and exploratory research as well as clinical applications.")
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .background(
                                    GeometryReader { geo -> Color in
                                        DispatchQueue.main.async {
                                            contentHeight = geo.size.height
                                        }
                                        return Color.clear
                                    }
                                )
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetKey.self,
                                                        value: -geo.frame(in: .named("scroll")).origin.y)
                                    }
                                )
                        }
                        .coordinateSpace(name: "scroll")
                        .frame(height: 300) // Limit height to enable scrolling
                        .background(
                            GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    scrollViewHeight = geo.size.height
                                }
                                return Color.clear
                            }
                        )
                        .onPreferenceChange(ScrollOffsetKey.self) { value in
                            // Scroll offset is positive when content moves up, so clamp at 0 and max scroll
                            scrollOffset = max(0, value)
                        }

                        // Custom scrollbar
                        if contentHeight > scrollViewHeight {
                            let maxScroll = max(contentHeight - scrollViewHeight, 0)
                            let clampedScrollOffset = min(max(scrollOffset, 0), maxScroll)
                            let scrollProgress = maxScroll > 0 ? (clampedScrollOffset / maxScroll) : 0
                            let visibleRatio = scrollViewHeight / contentHeight
                            let thumbHeight = max(scrollViewHeight * visibleRatio, 40)
                            let thumbTop = scrollProgress * (scrollViewHeight - thumbHeight)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray)
                                .frame(width: 5, height: thumbHeight)
                                .padding(.trailing, 4)
                                .offset(y: thumbTop)
                                .animation(.easeInOut(duration: 0.15), value: thumbTop)
                        }
                        
                    }
                    .frame(height: scrollViewHeight)
                    .clipped()

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

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
