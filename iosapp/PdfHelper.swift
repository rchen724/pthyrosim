import SwiftUI
import UIKit

// This function takes any SwiftUI View and renders it into a PDF.
@MainActor
func renderViewToPDF<V: View>(view: V) async -> URL {
    let url = URL.documentsDirectory.appending(path: "graph_export.pdf")
    let renderer = ImageRenderer(content: view)

    // The renderer needs the view's context to determine the correct size.
    // This happens synchronously.
    renderer.render { size, context in
        // Define the PDF page size based on the view's actual size.
        var box = CGRect(origin: .zero, size: size)
        
        // Create the PDF context.
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return
        }
        
        // Start a new PDF page.
        pdf.beginPDFPage(nil)
        
        // Draw the captured view into the PDF.
        context(pdf)
        
        // Close the page and the document.
        pdf.endPDFPage()
        pdf.closePDF()
    }
    
    // Return the URL where the file is now saved.
    return url
}


// A helper struct to wrap the iOS Share Sheet (UIActivityViewController) for use in SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
