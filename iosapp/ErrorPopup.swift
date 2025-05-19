//
//  ErrorPopup.swift
//  iosapp
//
//  Created by Rita Chen on 5/18/25.
//

import SwiftUI

struct ErrorPopup: View {
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Text("Error")
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)

            Button("OK") {
                onDismiss()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 280, height: 200)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
    }
}
