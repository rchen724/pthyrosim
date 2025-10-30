import SwiftUI

/// Drop-in ScrollView replacement that shows a slim custom scrollbar on the right.
struct ScrollViewWithScrollbar<Content: View>: View {
    let showsIndicators: Bool
    let content: () -> Content

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var scrollViewHeight: CGFloat = 1

    // Tweakables
    private let thumbWidth: CGFloat = 8
    private let thumbMinHeight: CGFloat = 8    // was 10
    private let thumbCorner: CGFloat = 3
    private let thumbOpacity: Double = 0.8    // slightly lighter
    private let sidePadding: CGFloat = 4      // was 4
    private let animationDuration: Double = 0.5 // was 0.15 (slower)
    private let visibleScale: CGFloat = 0.15   // was 0.25 (slightly smaller thumb)

    init(showsIndicators: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.showsIndicators = showsIndicators
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: showsIndicators) {
                VStack(spacing: 0) {
                    // Track current scroll offset
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            self.scrollOffset = -geo.frame(in: .named("scroll")).origin.y
                        }
                        return .clear
                    }
                    .frame(height: 0)

                    content()
                        // Measure content height
                        .background(
                            GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    self.contentHeight = geo.size.height
                                }
                                return .clear
                            }
                        )
                }
            }
            .coordinateSpace(name: "scroll")
            // Measure scroll view height
            .background(
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        self.scrollViewHeight = geo.size.height
                    }
                    return .clear
                }
            )

            // Custom scrollbar thumb
            if contentHeight > scrollViewHeight {
                let maxScroll = max(contentHeight - scrollViewHeight, 1)
                let clampedScroll = min(max(scrollOffset, 0), maxScroll)
                let progress = clampedScroll / maxScroll
                let visibleRatio = scrollViewHeight / contentHeight
                let thumbHeight = max(scrollViewHeight * visibleRatio * visibleScale, thumbMinHeight)
                let thumbTop = progress * (scrollViewHeight - thumbHeight)

                RoundedRectangle(cornerRadius: thumbCorner)
                    .fill(Color.gray.opacity(thumbOpacity))
                    .frame(width: thumbWidth, height: thumbHeight)
                    .padding(.trailing, sidePadding)
                    .offset(y: thumbTop)
                    .animation(.easeInOut(duration: animationDuration), value: thumbTop)
            }
        }
    }
}
