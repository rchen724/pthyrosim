import SwiftUI
import UIKit

// Shared index for the custom TabBar
// 0: Intro, 1: Input, 2: Run 1, 3: Dose 2, 4: Run 2, 5: More
let kMoreTabIndex = 5

enum RootTab: String {
    case run2
    case more
}

struct MainView: View {
    // Remove this if you don't use it elsewhere
    @AppStorage("rootTabSelection") private var rootTabSelection: String = RootTab.run2.rawValue

    // ⬇️ Make the tab index shared via AppStorage
    @AppStorage("selectedMainTab") private var selectedTab: Int = 0
    
    private let tabs = [
        TabItem(title: "Intro",  icon: "info.circle.fill",             view: AnyView(IntroView())),
        TabItem(title: "Input",  icon: "slider.horizontal.3",          view: AnyView(Step1View())),
        TabItem(title: "Run 1",  icon: "chart.bar.xaxis",              view: AnyView(SimulationView())),
        TabItem(title: "Dose 2", icon: "pills.fill",                   view: AnyView(Run2DosingInputView())),
        TabItem(title: "Run 2",  icon: "chart.xyaxis.line",            view: AnyView(Run2View())),
        TabItem(title: "More",   icon: "ellipsis.circle.fill",         view: AnyView(MoreTabView()))
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                ZStack {
                    Color.black.ignoresSafeArea(.all)
                    tabs[selectedTab].view
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom tab bar
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button {
                            selectedTab = index
                        } label: {
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
        .onAppear {
            // Force Intro each time the root view appears
            selectedTab = 0
        }
    }
}

struct TabItem {
    let title: String
    let icon: String
    let view: AnyView
}
