//
//  BulletView.swift
//  iosapp
//
//  Created by Rita Chen on 10/25/25.
//
import SwiftUI

struct BulletRow: View {
    let text: String
    private let bulletWidth: CGFloat = 16   // keeps all bullets aligned on one rail

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("•")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: bulletWidth, alignment: .leading)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(text.filter { $0 == "\n" }.count + 1)
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
    }
}
