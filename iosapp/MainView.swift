import SwiftUI
import UIKit

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            IntroView()
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("Intro")
                }
                .tag(0)

            Step1View()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Input")
                }
                .tag(1)

            SimulationView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Simulate Euthyroid")
                }
                .tag(2)
            
            Step2View()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Dosing")
                }
                .tag(3)

            Run2View()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Simulate Dosing")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            // Make tab bar black
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
