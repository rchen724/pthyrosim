import SwiftUI
import UIKit

// MARK: - Drop-in activity sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Safer iPad anchor to avoid "blank" presentation on iPad-style environments
        if let pop = vc.popoverPresentationController {
            let keyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            pop.sourceView = keyWindow
            pop.sourceRect  = CGRect(x: UIScreen.main.bounds.midX,
                                     y: UIScreen.main.bounds.maxY - 40,
                                     width: 1, height: 1)
            pop.permittedArrowDirections = []
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Minimal test view
struct ShareSheetSmokeTestView: View {
    @State private var url: URL?
    @State private var show = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Share Sheet Smoke Test").font(.title2)
            Button("Create & Share Test File") {
                // 1) Write a tiny file to a valid location
                let tmp = FileManager.default.temporaryDirectory
                let test = tmp.appendingPathComponent("share-test-\(UUID().uuidString).txt")
                do {
                    try "hello share".data(using: .utf8)?.write(to: test, options: .atomic)
                    guard FileManager.default.fileExists(atPath: test.path) else {
                        print("❌ File missing at path: \(test.path)")
                        return
                    }
                    print("✅ Wrote file: \(test.path)")
                    url = test
                    show = true                           // 2) present only after it exists
                } catch {
                    print("❌ Write error:", error.localizedDescription)
                }
            }
        }
        .padding()
        .sheet(isPresented: $show) {
            if let url {
                ShareSheet(items: [url])              // 3) share *file URL*
            } else {
                Text("Preparing…").padding()
            }
        }
    }
}
