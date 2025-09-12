import SwiftUI
import UIKit

struct MainView: View {
    @State private var selectedTab = 0
    
    // Define main tabs (5 tabs + More tab)
    private let tabs = [
        TabItem(title: "Intro", icon: "info.circle.fill", view: AnyView(IntroView())),
        TabItem(title: "Input", icon: "slider.horizontal.3", view: AnyView(Step1View())),
        TabItem(title: "Run 1", icon: "chart.bar.xaxis", view: AnyView(SimulationView())),
        TabItem(title: "Dose 2", icon: "pills.fill", view: AnyView(Step2View())),
        TabItem(title: "Run 2", icon: "chart.xyaxis.line", view: AnyView(Run2View())),
        TabItem(title: "More", icon: "ellipsis.circle.fill", view: AnyView(MoreTabView()))
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Main content area with black background
                ZStack {
                    Color.black.ignoresSafeArea(.all)
                    tabs[selectedTab].view
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom tab bar
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: tabs[index].icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                                
                                Text(tabs[index].title)
                                    .font(.system(size: 9))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .background(Color.black)
                .frame(height: 60)
            }
        }
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// Tab item structure
struct TabItem {
    let title: String
    let icon: String
    let view: AnyView
}
