//
//  RegistrationTextField.swift
//  Still
//

import SwiftUI

struct RegistrationTextField: View {
    let title: String
    let prompt: String
    @Binding var text: String

    var body: some View {
        RegistrationField(title: title) {
            TextField(
                "",
                text: $text,
                prompt: Text(prompt)
                    .foregroundStyle(StillColors.Content.teriary)
            )
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(StillColors.Content.primary)
        }
    }
}
