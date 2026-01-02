//
//  CompactDoseButton.swift
//  iosapp
//
//  Created by Ashwin Joshi on 12/1/25.
//

import Foundation
import SwiftUI

func compactDoseButton(image: String, text: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack(spacing: 12) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
}
