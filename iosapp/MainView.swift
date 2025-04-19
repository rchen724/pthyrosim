import SwiftUI
import UIKit

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            IntroView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("INTRO")
                }
                .tag(0)

            Step1View()
                .tabItem {
                    Image(systemName: "person")
                    Text("STEP 1")
                }
                .tag(1)

            Step2View()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("STEP 2")
                }
                .tag(2)

            SimulationView()
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("SIMULATE")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Make tab bar black
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
