//
//  printSnapshot.swift
//  iosapp
//
//  Created by Rita Chen on 6/16/25.
//

import SwiftUI
import UIKit

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // Let the controller size itself to fit content:
        controller.view.bounds = CGRect(origin: .zero, size: CGSize(width: 350, height: 10000))
        controller.view.backgroundColor = .clear
        
        // Force layout:
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        
        // Calculate fitting size:
        let targetSize = controller.sizeThatFits(in: CGSize(width: 350, height: CGFloat.greatestFiniteMagnitude))
        
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

func printGraphImage(_ image: UIImage, completion: @escaping () -> Void) {
    let printController = UIPrintInteractionController.shared
    let printInfo = UIPrintInfo(dictionary: nil)
    printInfo.outputType = .photo
    printInfo.jobName = "Simulation Graph"
    printController.printInfo = printInfo
    printController.printingItem = image

    printController.present(animated: true) { _, completed, error in
        completion()
    }
}

func startPrintJob(completion: @escaping () -> Void) {
    // Prepare your print formatter or image
    let printController = UIPrintInteractionController.shared
    // Configure printController with your content...

    printController.present(animated: true) { (_, completed, error) in
        // Called when printing finishes or is canceled
        completion()
    }
}
