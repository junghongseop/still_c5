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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)

            TextField(
                "",
                text: $text,
                prompt: Text(prompt)
                    .foregroundStyle(StillColors.Content.teriary)
            )
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(StillColors.Content.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(StillColors.Surface.raised)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(StillColors.Border.subtle, lineWidth: 1)
            }
        }
    }
}
