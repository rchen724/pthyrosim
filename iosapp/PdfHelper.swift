import SwiftUI
import UIKit

// This function takes any SwiftUI View and renders it into a PDF.
    @MainActor
    func renderViewToPDF<V: View>(view: V) async -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("share-export-\(UUID().uuidString).pdf")
        let renderer = ImageRenderer(content: view)
        
        let data = NSMutableData()

        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            
            guard let consumer = CGDataConsumer(data: data),
                  let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return
            }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            // Error handling for writing PDF data is optional; for simplicity, we'll just let it fail silently here.
        }
        
        return url
    }

