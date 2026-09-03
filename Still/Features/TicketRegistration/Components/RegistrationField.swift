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
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(StillColors.Surface.raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                }
        }
    }
}
