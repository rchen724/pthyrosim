import SwiftUI

struct MainView: View {
    @EnvironmentObject var simulationData: SimulationData
    @AppStorage("selectedMainTab") private var selectedTab: Int = 0

    // Token used to reset More tab's NavigationStack when re-tapping it
    @AppStorage("moreTabResetToken") private var moreTabResetToken: String = ""

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
                            if selectedTab == index {
                                // If re-tapping the already-selected "More" tab (index 5),
                                // bump the token to force MoreTabView to pop to root.
                                if index == 5 {
                                    moreTabResetToken = UUID().uuidString
                                }
                            } else {
                                selectedTab = index
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tabs[index].icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                                Text(tabs[index].title)
                                    .font(.system(size:  9))
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
            // Optional: force Intro on launch
            selectedTab = 0
            LaunchResetManager.resetOnColdLaunch(simulationData: simulationData)

        }
    }
}

struct TabItem {
    let title: String
    let icon: String
    let view: AnyView
}
