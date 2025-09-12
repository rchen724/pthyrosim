import SwiftUI

struct MoreTabView: View {
    @State private var selectedSubTab = 0
    
    private let subTabs = [
        SubTabItem(title: "Dose 3", icon: "pills.circle.fill", view: AnyView(Run3DosingInputView())),
        SubTabItem(title: "Run 3", icon: "chart.line.uptrend.xyaxis", view: AnyView(Run3View()))
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("More Options")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Run 3 Dosing and Simulation")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                .padding(.bottom, 20)
                
                // Sub-tab navigation
                HStack(spacing: 0) {
                    ForEach(0..<subTabs.count, id: \.self) { index in
                        Button(action: {
                            selectedSubTab = index
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: subTabs[index].icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedSubTab == index ? .blue : .gray)
                                
                                Text(subTabs[index].title)
                                    .font(.system(size: 10))
                                    .foregroundColor(selectedSubTab == index ? .blue : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedSubTab == index ? 
                                Color.blue.opacity(0.2) : Color.clear
                            )
                        }
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Content area with black background
                ZStack {
                    Color.black.ignoresSafeArea(.all)
                    subTabs[selectedSubTab].view
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.black.ignoresSafeArea(.all))
    }
}

struct SubTabItem {
    let title: String
    let icon: String
    let view: AnyView
}
