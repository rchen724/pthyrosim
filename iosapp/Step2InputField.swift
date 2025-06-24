//
//  Step2InputField.swift
//  iosapp
//
//  Created by Shruthi Sathya on 6/17/25.
//

//
//  Step2InputField.swift
//  iosapp
//
//  Created by Gemini
//

import SwiftUI

struct Step2InputField: View {
    var title: String // Placeholder text for the text field
    @Binding var value: String
    var keyboardType: UIKeyboardType = .decimalPad

    var body: some View {
        TextField(title, text: $value)
            .padding(10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.black)
            .keyboardType(keyboardType)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
    }
}
