//
//  MethodSelectionButton.swift
//  Still
//

import SwiftUI

struct MethodSelectionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)

                Text(title)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(StillColors.Content.primary)
            .background(StillColors.Surface.raised)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(StillColors.Border.subtle, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MethodSelectionButton(
        title: "카메라",
        systemImage: "camera"
    ) {}
}
