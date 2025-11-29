import SwiftUI

struct MainView: View {
    @EnvironmentObject var simulationData: SimulationData
    @AppStorage("selectedMainTab") private var selectedTab: Int = 0
    @State private var showingResetAlert = false

    private let tabs = [
        TabItem(title: "Intro",  icon: "info.circle.fill",             view: AnyView(IntroView())),
        TabItem(title: "Input",  icon: "slider.horizontal.3",          view: AnyView(Step1View())),
        TabItem(title: "Run 1",  icon: "chart.bar.xaxis",              view: AnyView(SimulationView())),
        TabItem(title: "Run 2",  icon: "chart.xyaxis.line",            view: AnyView(Run2View())),
        TabItem(title: "Run 3",  icon: "chart.line.uptrend.xyaxis",    view: AnyView(Run3View())),
        TabItem(title: "Run 4",  icon: "chart.line.downtrend.xyaxis",  view: AnyView(Run4View()))
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                resetButtonView
                tabViewContent
                customTabBarView
            }
        }
        .background(Color.black.ignoresSafeArea(.all))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            // Optional: force Intro on launch
            selectedTab = 0
            LaunchResetManager.resetOnColdLaunch(simulationData: simulationData)
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Confirm Reset"),
                message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    LaunchResetManager.resetAll(simulationData: simulationData)
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var resetButtonView: some View {
        HStack {
            Spacer()
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.counter.clockwise")
                    Text("Reset All")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
        .background(Color.black)
    }

    private var tabViewContent: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            tabs[selectedTab].view
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var customTabBarView: some View {
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

struct TabItem {
    let title: String
    let icon: String
    let view: AnyView
}
