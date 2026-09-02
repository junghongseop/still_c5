//
//  RegistrationField.swift
//  Still
//

import SwiftUI

struct RegistrationField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.still(.label))
                .foregroundStyle(StillColors.Content.secondary)

            content
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)
                .background(StillColors.Surface.raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                }
        }
    }
}
